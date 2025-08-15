import sys
from datetime import datetime
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Get job parameters
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Main job logic
print(f"🕐 Current time: {datetime.now()}")
print("✅ Simple Glue job completed successfully!")

# Commit and stop job
job.commit()
sc.stop()