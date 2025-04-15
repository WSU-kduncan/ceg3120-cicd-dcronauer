# Use node:18 as the base image
FROM node:18

# Set the working directory inside the container
WORKDIR /usr/src/app

# Install unzip (needed for unzipping the downloaded angular.zip)
# RUN apt-get update && apt-get install -y unzip curl

# copy everything
COPY . .

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Set the working directory to the Angular project directory
WORKDIR /usr/src/app/angular-site/wsu-hw-ng-main

# Install the dependencies for the Angular project
RUN npm install

# Expose the port on which the Angular app will run
EXPOSE 4200

# Start the Angular app (serve on all interfaces so it can be accessed from outside the container)
CMD ["ng", "serve", "--host", "0.0.0.0", "--port", "4200"]

