if [ "$1" == "" ]
then
  echo "Usage: bash $0 <stage>"
  exit
fi

STAGE=$1
APP_NAME="express-beanstalk-$STAGE"
REGION="us-east-1"
PLATFORM="node.js-16"

echo "Initializing $APP_NAME at $REGION with $PLATFORM..."
eb init $APP_NAME --region $REGION --platform $PLATFORM

echo "Checking for environment $APP_NAME..."
eb use $APP_NAME
if [ $? -eq 0 ]; then
  eb deploy $APP_NAME
else
  eb create $APP_NAME
fi

