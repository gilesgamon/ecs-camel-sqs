# ECS uses an amazolinlinux:1 instance and is built to support docker
# However, in debugging the containers (with credentials especilly) it's useful to be 'able' to run
# the java by hand. This sets up the container to allow that

yum -y update

# Install NodeJS 12
curl -sL https://rpm.nodesource.com/setup_12.x | bash -
yum clean all && yum makecache fast
yum install -y deltarpm gcc-c++ make nodejs zip unzip git curl tar wget make gzip zip zlib-devel gcc openssl-devel bzip2-devel libffi-devel file hostname java-11-amazon-corretto python36

# Setup env vars
export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto.x86_64
export PATH=$JAVA_HOME/bin:~/.local/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install PIP
cd /tmp
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install --upgrade --user awscli

# Install OpenJDK 11 (that we get with amazonlinux:2)
curl -o java-11-amazon-corretto-headless-11.0.6.10-1.amzn2.x86_64.rpm https://corretto.aws/downloads/resources/11.0.6.10.1/java-11-amazon-corretto-headless-11.0.6.10-1.amzn2.x86_64.rpm
curl -o java-11-amazon-corretto-11.0.6.10-1.amzn2.x86_64.rpm https://corretto.aws/downloads/resources/11.0.6.10.1/java-11-amazon-corretto-11.0.6.10-1.amzn2.x86_64.rpm
yum localinstall -y java-11-amazon-corretto-headless-11.0.6.10-1.amzn2.x86_64.rpm java-11-amazon-corretto-11.0.6.10-1.amzn2.x86_64.rpm

# Get credentials from the camel container running
export CONTAINER=`docker ps|grep camel|awk '{print $1}'`
export `docker inspect $CONTAINER|grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI| cut -d \" -f2`
curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI > /tmp/creds

# Load the creds into env vars
export AWS_CREDS=`cat /tmp/creds`
export AccessKeyId=`node -pe 'JSON.parse(process.env.AWS_CREDS).AccessKeyId'`
export SecretAccessKey=`node -pe 'JSON.parse(process.env.AWS_CREDS).SecretAccessKey'`
export SessionToken=`node -pe 'JSON.parse(process.env.AWS_CREDS).Token'`
echo export AccessKeyId=`node -pe 'JSON.parse(process.env.AWS_CREDS).AccessKeyId'`
echo export SecretAccessKey=`node -pe 'JSON.parse(process.env.AWS_CREDS).SecretAccessKey'`
echo export SessionToken=`node -pe 'JSON.parse(process.env.AWS_CREDS).Token'`
# copy out the jar & jks
cp `find /var -name broker-1.0-SNAPSHOT.jar -print` .
cp `find /var -name server-chain.jks -print` .

# Run the code
java -Daws.AccessKeyId=${AccessKeyId} -Daws.SecretAccessKey=${SecretAccessKey} -Daws.SessionToken=${SessionToken} -jar broker-1.0-SNAPSHOT.jar
