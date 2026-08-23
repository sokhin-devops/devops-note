#!/bin/bash
docker build -t my-projects-image:latest .

docker rm -f my-projects-container
docker run -d --name my-projects-container -p 8080:80 my-projects-image:latest