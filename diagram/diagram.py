# diagram.py
# Needs diagrams from pip and graphwiz installed
from diagrams import Cluster, Diagram
#from diagrams.aws.network.ElasticLoadBalancing import ELB
from diagrams.aws.compute.ApplicationAutoScaling import Scale
from diagrams.aws.compute.EC2 import EC2
from diagrams.aws.database.RDS import RDS
from diagrams.aws.network.Route53 import Route53
from diagrams.aws.storage.SimpleStorageServiceS3 import S3

with Diagram("Artifactory", show=False):
    dns = Route53("dns")
    lb = ELB("lb")

    with Cluster("DB Security Group"):
        RDS("MySql")

   # with Cluster("App Security"):

  #  with Cluster("ELB Security"):


#autoscaling ->elb

#elo
#rds instance-db Security group
#instance profile
