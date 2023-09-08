#!/bin/bash

stop_container_ifexists() {
    local container_name=$1

    if [ "$(docker ps -aq -f name=${container_name})" ]; then
        # if the container exists, stop and remove it
        echo "Stopping and removing '${container_name}' container."
        docker rm -f ${container_name}
    fi
}

stop_remove_containers(){  
    for i in {1..9}
    do
        container_name="mapper-$i"
        stop_container_ifexists $container_name
    done
    stop_container_ifexists 'reducer'
}

remove_volume_ifexists() {
    if [ "$(docker volume ls -q -f name=shared_titles)" ]; then
        # if the volume exists, remove it
        echo "Removing existing 'shared_titles' volume"
        docker volume rm shared_titles
    fi
}

echo -e "\nStopping and removing any mapper and reducer containers...\n"
stop_remove_containers

# check if volume exists, remove it if it does and create new one to be shared among containers
remove_volume_ifexists
echo -e "Creating 'shared_titles' volume be shared among containers"
docker volume create shared_titles

# create 9 map containers
echo -e "\nCreating the 9 mapper containers ..."
for i in {1..9}
do
    container_name="mapper-$i"
    echo -e "\nCreating new container '$container_name' ..."
    # # Run the container in detached mode and mount the named volume
    docker run -d \
      --name $container_name \
      -v shared_titles:/HW2_part2/ \
      map-reduce \
      tail -f /dev/null
done

# create 1 reduce container
echo -e "\nCreating the 'reducer' container ..."
docker run -d \
      --name 'reducer' \
      -v shared_titles:/HW2_part2/ \
      map-reduce \
      tail -f /dev/null

echo -e "\nExcuting reduce.py in the 'reducer' container"
# execute the reduce.py script in the reducer container
# obs.: doing it first on purpose, to see if will wait correctly for the other containers to finish
docker exec -d reducer python /HW2_part2/reduce.py

echo -e "\nExcuting map.py in each of the 'mapper' containers"
# execute the map.py i script in each container
# obs: this could go into the above loop, but doing it separate to test
#      the container "orchestration" is working
for i in {1..9}
do
    docker exec -d mapper-$i python /HW2_part2/map.py $i
done

# loop until the total_counts.json file is created and copy it to host machine
echo -e "\nWaiting for the map-reduce to finish..."
while [ -z "$file_path" ]; do
    file_path=$(docker exec reducer find /HW2_part2/counts/ -name "total_counts.json")
    sleep 1
done

echo -e "\nCopying total_counts to host working directory"
docker cp reducer:$file_path .

echo -e "\nCleaning host machine of containers and volume..."
stop_remove_containers

echo -e "\nRemoving 'shared_titles' volume"
docker volume rm shared_titles