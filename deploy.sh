#!/bin/bash -x
# Environment variables
export THEME_URL="https://github.com/klugjo/hexo-theme-alpha-dust"
export THEME_NAME="alpha-dust"
export OLD_PATTERN="google_analytics: "
export NEW_PATTERN="google_analytics: UA-154191934-1"
export BLOGDIR="/git/blog.hackbox.link"

ls -ltrah $BLOGDIR

# Creating work dir
mkdir -pv "$BLOGDIR" && cd "$BLOGDIR"

# Fix Sources List     
sed -i /jessie-updates/d /etc/apt/sources.list

# Apt-Get Update
apt-get update
 
# Install Git
apt-get install -yq git

# Install Curl
apt-get install -yq curl

# Install NodeJS
apt-get install -y nodejs

# Install Curl
apt-get install -yq curl

# Install NVM
curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh -o install_nvm.sh
#command -v nvm
#nvm install 9.9.0
chmod a+x install_nvm.sh
./install_nvm.sh

find / -type f -name nvm

. ~/.bashrc && nvm install 9.9.0

#Install Node 9.9.0
#nvm install 9.9.0


#Install NPM
apt-get install -yq npm

#Install Python PIP
apt-get install -yq python-pip

#Install Hexo CLI
npm install -g hexo-cli

#Clean NPM cache
npm cache clear --force

#Install NPM Dependencies 
npm install --no-shrinkwrap --update-binary

#Debug NPM Install
#find /root/.npm/_logs/ -type f -exec cat {} \;

#Download theme
git clone $THEME_URL themes/$THEME_NAME

#Set Google Analytics
 sed -i "s/^$OLD_PATTERN.*/$NEW_PATTERN/g" themes/$THEME_NAME/_config.yml

#Debug Google Analytics
cat themes/$THEME_NAME/_config.yml

#Download Google Analytics Script
curl -sL https://raw.githubusercontent.com/elisboa/blog.hackbox.link/blog/google_analytics.ejs -o google_analytics.ejs

#Install Google Analytics Script on theme
cp -uva google_analytics.ejs themes/$THEME_NAME/layout/_partial

#Install Google Analytics Script on theme failsafe
cp -uva google_analytics.ejs themes/$THEME_NAME/layout/_partial/google-analytics.ejs

#Install Google Analytics Script on theme failsafe
cp -uva google_analytics.ejs themes/$THEME_NAME/google-analytics.ejs

#Debug Google Analytics Script
ls -ltrah themes/$THEME_NAME

#name: install theme dependencies
#command: | 
#  for npm_pack in 'hexo-renderer-pug-loader' 'hexo-renderer-stylus'
#  do  npm install "${npm_pack}" --save
#  done

#Set theme language
cp -fv themes/$THEME_NAME/languages/pt.yml themes/$THEME_NAME/languages/default.yml 

#      - run:
#          name: Remove public folder
#          command: |
#            rm -rfv public/*


#Generate static website
hexo generate

#Install Google Analytics Script on public dir
cp -uva google_analytics.ejs public

#Install Google Analytics Script on public dir failsafe
cp -uva google_analytics.ejs public/google-analytics.ejs

#Install AWS CLI
pip install awscli

#Debug info
cat /etc/os-release
hexo -v
node --version
ls -ltrahR public
hexo list route
hexo list post

#Push to S3 bucket
cd "$BLOGDIR/public"
aws s3 sync . s3://blog.hackbox.link --no-progress --delete

#Clean AWS CloudFront cache
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DIST_ID --paths /*

