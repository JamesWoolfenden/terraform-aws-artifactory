# diagram.py
# Needs diagrams from pip and graphwiz installed
from diagrams import Cluster, Diagram
#from diagrams.aws.network.ElasticLoadBalancing import ELB
from diagrams.aws.compute import AutoScaling
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import Route53
from diagrams.aws.network import ELB
from diagrams.aws.storage import S3


with Diagram("Artifactory", show=False):
    dns = Route53("dns")
    lb = ELB("lb")

    with Cluster("DB Security Group"):
        RDS("MySql")
        S3("Artifact Store")
