import urllib2, base64
import json

#AMBARI_HOST = raw_input("Ambari Host: ")
# PORT = input("PORT: ")
AMBARI_USER = raw_input("Ambari User: ")
AMBARI_PASSWD = raw_input("Ambari User Password: ")
CLUSTER_NAME = raw_input("Cluster Name: ")

#GRAFANA_HOST = raw_input("Grafana Host: ")

GRAFANA_HOST = '172.25.38.154'
AMBARI_HOST = '172.25.38.13'

Grafana_URL = "http://" + GRAFANA_HOST + ":3000/api/datasources/proxy/1/ws/v1/timeline/metrics?metricNames=regionserver.Server.regionCount._sum&hostname=&appId=hbase"
Ambari_URL = "http://" + AMBARI_HOST + ":8080/api/v1/clusters/" + CLUSTER_NAME + "/configurations?type="
user = AMBARI_USER
password = AMBARI_PASSWD


#def request_url (URL):
#    response = urllib2.Request(URL)
#    base64string = base64.b64encode('%s:%s' % (user, password))
#    response.add_header("Authorization", "Basic %s" % base64string)
#    result = json.load(urllib2.urlopen(response))
#    return

# Get Total number of regions from Grafana
test = urllib2.urlopen(Grafana_URL)
data = json.load(test)
for i in data['metrics']:
    tot_num_reg = i['metrics'].values()
    tot_num_reg = float(tot_num_reg[0])

# Get Latest HBASE-ENV TAG version from Ambari

response = urllib2.Request(Ambari_URL + "hbase-env")
base64string = base64.b64encode('%s:%s' % (user, password))
response.add_header("Authorization", "Basic %s" % base64string)
result = json.load(urllib2.urlopen(response))

for i in result['items']:
    tag_ver = i['tag']

# Get Region Server Heap
URL2 = Ambari_URL + "hbase-env" + "&tag=" + tag_ver

response = urllib2.Request(URL2)
base64string = base64.b64encode('%s:%s' % (user, password))
response.add_header("Authorization", "Basic %s" % base64string)
result = json.load(urllib2.urlopen(response))

for i in result['items']:
    x = i['properties']
    rs_heap = x['hbase_regionserver_heapsize']
    rs_heap = float(rs_heap)

# Get Latest HBASE-SITE TAG version from Ambari
URL3 = Ambari_URL + "hbase-site"
response = urllib2.Request(URL3)
base64string = base64.b64encode('%s:%s' % (user, password))
response.add_header("Authorization", "Basic %s" % base64string)
result = json.load(urllib2.urlopen(response))

for i in result['items']:
    tag_ver_site = i['tag']

# Get memstore flush and fraction

URL4 = URL3 + "&tag=" + tag_ver_site
response = urllib2.Request(URL4)
base64string = base64.b64encode('%s:%s' % (user, password))
response.add_header("Authorization", "Basic %s" % base64string)
result = json.load(urllib2.urlopen(response))

for i in result['items']:
    x = i['properties']
    memstore_flush = x['hbase.hregion.memstore.flush.size']
    memstore_flush = float(memstore_flush)
    memstore_fraction = x['hbase.regionserver.global.memstore.size']
    memstore_fraction = float(memstore_fraction)

# How many Region servers we have
URL5 = "http://172.25.38.13:8080/api/v1/clusters/c2150/services/HBASE/components/HBASE_REGIONSERVER"
response = urllib2.Request(URL5)
base64string = base64.b64encode('%s:%s' % (user, password))
response.add_header("Authorization", "Basic %s" % base64string)
result = json.load(urllib2.urlopen(response))

x = result['ServiceComponentInfo']
rs_count = x['total_count']
rs_count = float(rs_count)

max_reg_t = (((rs_heap * memstore_fraction) / ((memstore_flush / 1024) / 1024))) * rs_count
max_reg_t = float(max_reg_t)

if tot_num_reg > max_reg_t:
    print "WARNING: Total number of regions" + tot_num_reg +"has exceeded regions Upper_limit" + max_reg_t
else:
    print "Total number of regions is " + str(tot_num_reg) + ", its still safe. It should not exceed " + str(max_reg_t)