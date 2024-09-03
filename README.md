# Track Data API / Database / Dashboard for Torque Pro

Looking for a way to use Torque Pro Web Server Data API?! ... Look no further below will layout a way to deploy a Web Server , Database and Dashboard all at once to analyze data sent from your ODBII stats.

# Couple things required before you get started
1. Cloud Hosted Service - Debian or Ubuntu ( You can selfhost but since the data will be sent from your mobile device I wouldnt open your web server to the world )
3. Web Application Firewall - Cloudflare is free if you own a domain already. ( Super simple firewall rules to off load any unwanted traffic on them instead of your web server or cloud provider )

# After spinning up your Debian or Ubuntu server and SSHing into the server Run the following commands
1. sudo apt update && sudo apt upgrade -y
2. sudo apt install git
3. git clone https://github.com/Rasperss/Track-Data.git
4. chmod +x create_user_update.sh
5. nano create_user_update.sh (change the password for the user "racing")
6. sudo ./create_user_update.sh (server will reboot and create the user)
7. ssh back into the server with the new user " racing " and whatever password you set.
8. sudo mv -r /root/api /home/racing/api
9. sudo mv /root/everything_else.sh /home/racing/everything_else.sh
10. sudo chown racing:racing everything_else.sh
11. chmod +x everything_else.sh
12. nano everything_else.sh (change all the passwords for Influxdb & Grafana, also include the .pem for your domain or change the haproxy config from " *:443 ssl crt /path/to/cert " to " *:80 ")
13. ./everything_else.sh
14. cd /home/racing/docker
15. sudo docker compose up -d
16. Login to your InfluxDB server (http://[public IP]:8086) [You may need create a firewall rule on your cloud provider to allow the connection]
17. Create your account, admin + password, Create your Org name " Racing ".
18. Go to Data, create a bucket called track-data.
19. Go to the Token tab and generate a new token. (call it Tomcat and save the token)
20. Now generate a Bearer Token for the java api (multiple different ways to do this, or just create a secret key, whatever)
21. nano /home/racing/api/src/main/java/com/api/InfluxdbDataInject.java (add the Bearer token you created to the file. And add your InfluxDB token to it as well)
22. cd /home/racing/api
23. mvn clean package
24. cp /home/racing/api/target/api.war /home/racing/tomcat/api.war
25. sudo docker restart tomcat

# With all those ridiclously long steps completed you should have a working api

# Now lets get Torque Pro configured
1. Go to your app settings and go to the Data Logging.
2. Input your web server address. ( https://[yourdomain or public IP]/api/upload - use http if you dont have a cert )
3. Input your bearer token you created and put in the java file
4. set your logging intervals

# Once connected to your car you should start to send data
