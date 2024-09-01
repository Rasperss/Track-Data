# Track Data API / Database / Dashboard for Torque Pro

Looking for a way to use Torque Pro Web Server Data API?! ... Look no further below will layout a way to deploy a Web Server , Database and Dashboard all at once to analyze data sent from your ODBII stats.

# Couple things required before you get started
1. Cloud Hosted Service - Debian or Ubuntu ( You can selfhost but since the data will be sent from your mobile device I wouldnt open your web server to the world )
2. Web Application Firewall - Cloudflare is free if you own a domain already. ( Super simple firewall rules to off load any unwanted traffic on them instead of your web server )

# After spinning up your Debian or Ubuntu server Run the following commands
1. sudo apt update && sudo apt upgrade -y
2. sudo apt install git
3. git clone https://github.com/Rasperss/Track-Data.git
