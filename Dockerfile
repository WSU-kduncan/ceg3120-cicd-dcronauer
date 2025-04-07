# Use Node.js 18 Bullseye as the base image
FROM node:18-bullseye

# Set the working directory for the container
WORKDIR /app

# Install Angular CLI globally
RUN npm install -g @angular/cli


# Install application dependencies
RUN npm install

# Copy the rest of your Angular app's files into the container
COPY . .

# Expose the port for the Angular app (default is 4200)
EXPOSE 4200

# Command to run the Angular app
CMD ["ng", "serve", "--host", "0.0.0.0"]
