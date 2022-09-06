import boto3
import sys
import logging
import os
from PIL import Image
import PIL.Image

s3_client = boto3.client('s3')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def resize_image(file_name):
    """
    To resize the image
    """
    try:

        file=file_name.split(".")[0]
        ext=file_name.split(".")[1]

        file_path=f"/tmp/{file_name}"
        logger.info(f"Started resizing image at {file_path}")

        with Image.open(file_path) as image:

            width, height = image.size
            ratio=width/height
            width_sizes=[240,480,960]
            
            for i in width_sizes:

                try:
                    h=i//ratio
                    
                    newsize = (i, int(h))
                    image = image.resize(newsize)
                    image.save(f"/tmp/{file}_{i}.{ext}")

                    logger.info(f"Converted image : /tmp/{file}_{i}.{ext}")

                except Exception as e:
                    logger.error(f" Error while converting image {file} for size width {i} size - {e}")

    except Exception as e:
        logger.error(f"Failed resizing image at {file_path} - {e}")

def clean_up(file_name):
    """
    Cleaning the tmp files
    """
    try:
        logger.info("Cleaning up the files")

        file=file_name.split(".")[0]
        ext=file_name.split(".")[1]

        files=[f"/tmp/{file}_{i}.{ext}" for i in [240,480,960]]
        files.append(f"/tmp/{file_name}")

        for file in files:
            if(os.path.isfile(file)):
                logger.info(f"Cleaning - {file}")
                os.remove(file)

        logger.info("Cleanup is over")

    except Exception as e:
        logger.error(f"Error in cleanup - {e}")

def upload_images(file_name, bucket):
    """
    Upload Images
    """
    try:
        logger.info("Uploading the files")

        file=file_name.split(".")[0]
        ext=file_name.split(".")[1]

        files=[f"/tmp/{file}_{i}.{ext}" for i in [240,480,960]]

        for file in files:
            if(os.path.isfile(file)):
                logger.info(f"Uploading - {file}")

                key= file.replace("/tmp/","")
                upload_key = f"Processed_Images/{key}"
                extension = f"image/{ext}"

                s3_client.upload_file(file, bucket, upload_key, ExtraArgs={'ContentType':extension})
                logger.info(f"Uploading completed - {file}")

            else:
                logger.error(f"File {file} not found for upload")

        logger.info("Upload is over")

    except Exception as e:
        logger.error(f"Upload Error - {e}")

def lambda_handler(event, context):

    try:
        for record in event['Records']:

            try:

                bucket = record['s3']['bucket']['name']
                object_key = record['s3']['object']['key']
                file_name = object_key.split('/')[1] 

                if(object_key == "Images/"):
                    logger.info("Ignoring the Folder")
                else:

                    logger.info(f"Working on Bucket {bucket} and object {object_key}")
                    download_path = f"/tmp/{file_name}"                  
                    
                    logger.info(f"Downloading file to {download_path}")
                    s3_client.download_file(bucket, object_key, download_path)

                    resize_image(file_name)

                    upload_images(file_name,bucket)

                    clean_up(file_name)

            except Exception as e:
                logger.info(f"Error while processing image - {e}")
                
        logger.info("Done with the resizing")

    except Exception as e:
        logger.error(f"Error in main lambda - {e}")
    