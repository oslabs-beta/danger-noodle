docker build -t armangurkan1/multi-client:latest -t armangurkan1/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t armangurkan1/multi-server:latest -t armangurkan1/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t armangurkan1/multi-worker:latest -t armangurkan1/multi-worker:$SHA -f ./worker/Dockerfile ./worker
docker push armangurkan1/multi-client:latest
docker push armangurkan1/multi-server:latest
docker push armangurkan1/multi-worker:latest
docker push armangurkan1/multi-client:$SHA
docker push armangurkan1/multi-server:$SHA
docker push armangurkan1/multi-worker:$SHA
kubectl apply -f k8s
kubectl set image deployments/server-deployment server=armangurkan1/multi-server:$SHA
kubectl set image deployments/client-deployment client=armangurkan1/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=armangurkan1/multi-worker:$SHA
