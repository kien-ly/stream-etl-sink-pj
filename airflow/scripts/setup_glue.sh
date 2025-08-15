#!/bin/bash

echo "🚀 Setting up simple Glue job..."

# 1. Upload script to S3 (replace with your bucket)
echo "📁 Upload script to S3:"
echo "aws s3 cp scripts/simple_glue_job.py s3://YOUR_BUCKET/scripts/"

# 2. Create Glue job
echo "🔧 Creating Glue job locally:"
python3 create_glue_job.py

# 3. Test run the job
echo "🧪 Test run Glue job:"
echo "aws glue start-job-run --job-name simple-time-job"

echo "✅ Setup complete!"
echo "📋 Next steps:"
echo "1. Replace YOUR_BUCKET and YOUR_ACCOUNT in the files"
echo "2. Run: aws s3 cp scripts/simple_glue_job.py s3://your-bucket/scripts/"
echo "3. Run: python3 create_glue_job.py"
echo "4. Deploy Airflow: ./deploy.sh"