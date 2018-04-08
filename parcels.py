import requests
import numpy as np
import json
from shapely.geometry import Polygon
from shapely import wkb
import psycopg2
import os
import redis
import functools
from flask_cors import CORS


REDIS_CACHE_VERSION = '1'
redis_connection = redis.StrictRedis(host='localhost', port=6379, db=0)
def redis_fetch_or_execute(key, executable):
    prefixed_key = f"{REDIS_CACHE_VERSION}-{key}"
    val = redis_connection.get(prefixed_key)
    if val:
        print(val)
        val = json.loads(val.decode('utf-8').replace("'", '"'))
    if not val:
        val = executable()
        redis_connection.set(prefixed_key, val)
    return val

def getPartCoords(location, part):    
    query = "select geom from parts_2016 where location = '"+location+"' and part = '"+part+"'"
    conn_string = "postgresql://rforjan:{}@138.68.66.142:5432/rforjan".format(os.environ['PG_PASS'])
    conn = psycopg2.connect(conn_string)
    curs = conn.cursor()
    curs.execute(query, (23,))  # one geometry
    geom = wkb.loads(curs.fetchone()[0], hex=True)
    return(geom.exterior.coords[:])  # [(x1, y1), (x2, y2)]


def latLongToXY(lat, long):
    i = 0.017453292519943
    
    if(lat > 0):
        lat = min(lat, 89.99999)
    else:
        lat = max(lat, -89.99999)
        
    a = lat * i
    return (long * i * 6378137, 3189068.5 * np.log((1 + np.sin(a)) / (1 - np.sin(a))))


def simplifyPolygon(p, vertTresh=30, tolInc=5):
    x,y = p.exterior.xy
    vertCount = len(x)
    tolerance = 0
    while vertCount > vertTresh:
        tolerance += tolInc 
        p = p.simplify(tolerance)
        x,y = p.exterior.xy
        vertCount = len(x)
    return(p)

def xyToLatLong(x, y, i=0):
    a = 6378137
    n = 57.29577951308232
    o = 3.141592653589793
    lat = x / a * n
    if i:
        a1 = o/2 - 2*np.arctan(np.exp(-1*y/a))
        return(lat, a1*n)
    else:
        a2 = lat - 360 * np.floor((lat+180)/360)
        a3 = o/2 - 2*np.arctan(np.exp(-1*y/a))
        return [a3*n, a2]

def getOwners(id, parcel_type):
    url = "https://kataster.skgeodesy.sk/PortalOData/Parcels" + parcel_type + "(" + id + ")/Kn.Participants"
    r = requests.get(url)
    try:
        return r.json()
    except:
        return {}


from flask import Flask, request, jsonify
app = Flask(__name__)
CORS(app)


def get_result(location, part):
    print("getting parcels")
    # get and transform coordinates
    coords = getPartCoords(location, part)
    transformed_coords = [latLongToXY(a[1], a[0]) for a in coords]

    # create and simplify polygon
    diel = Polygon(transformed_coords)
    diel_area = diel.area
    simple_diel = simplifyPolygon(diel)
    x, y = simple_diel.exterior.xy

    # API call
    xmin = min(x) - 50
    xmax = max(x) + 50
    ymin = min(y) - 20
    ymax = max(y) + 20
    mapStr = "mapExtent=" + str(xmin) + "," + str(ymin) + "," + str(xmax) + "," + str(ymax)
    coordStr = str(list(zip(x, y))).replace(" ", "").replace("(", "[").replace(")", "]")
    url = "https://kataster.skgeodesy.sk/eskn/rest/services/VRM/identify/MapServer/identify?f=json&tolerance=0&returnGeometry=true&imageDisplay=1280,800,96&geometry={\"rings\":[" + coordStr + "]}&geometryType=esriGeometryPolygon&sr=102100&" + mapStr + "&layers=visible:1"

    r = requests.get(url)
    out = r.json()

    parcels = [
                {
                    'type': 'C' if parcel['layerId'] == 1 else 'E', 
                    'id': parcel['attributes']['ID'], 
                    'parcel_number': parcel['attributes']['PARCEL_NUMBER'],
                    'shape': parcel['geometry']['rings'][0],
                    'latLonShape': [
                        xyToLatLong(p[0], p[1]) for p in parcel['geometry']['rings'][0]
                    ]
                } 
                for parcel in out['results']
              ]

    output = []

    for p in parcels:
        shape = Polygon(p['shape'])
        intersect_area = shape.intersection(diel).area
        iarea = intersect_area / diel_area * 100
        if iarea > 5:
            p['owners'] = getOwners(p['id'], p['type'])
        if iarea > 1:
            p['intersect'] = iarea
            output.append(p)

    return output


def get_result_cached(location, part):
    key = f"{location}_{part}"
    return redis_fetch_or_execute(key, functools.partial(get_result, location=location, part=part))


@app.route('/parcels')
def parcels():
    # input
    # location = 'Belá nad Cirochou'
    # part = '0301/1'
    location = request.args.get('lokalita')
    part = request.args.get('diel')

    return jsonify(get_result(location, part))
