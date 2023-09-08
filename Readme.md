# Section 1

## Instructions to run application
1) Start the Docker engine
	- In the host machine, start the Docker engine using Docker desktop or by running `sudo service docker start` in the terminal

2) Clone/download the git repository in [link](https://github.com/mpcs-52040/homework-2-mshalimay)

3) In the command line,  navigate to `homework-2-mshalimay/part2`

4) Build the `map-reduce` image
	- In the command line, run `chmod +x build.sh | ./build.sh`
	- **Description**: this will execute a bash script that creates a Dockerfile and build the Docker image with following specs:
		- python 3
		- a copy of `map.py`, `reduce.py`  and `titles.tar.gz` to the `HW2_part2` folder of the container filesystem
		- unzip the `titles.tar.gz` folder
		- create in the container filesystem a directory called `counts` 
	- To check the image was created run `docker image ls` in the command line

5) Run the map-reduce using the `mapper` and `reducer` containers
	- In the command line, run `chmod +x count.sh | ./count.sh`
	- **Description**: this will execute a bash script that:
		- stop and remove any existing `mapper-i` and `reducer` containers (i = 1 to 9) 
		- remove any existing 'shared_titles' volume and create a new one based on the `HW2_part2` folder for data sharing between the containers
		- Create the 9 mapper containers binded to the `shared_titles` volume
		- Create the 1 reducer container binded to the `shared_titles` volume
		- Execute `reduce.py` in the reducer container and `map.py` in each of the 9 mapper containers
		- Loop until the map-reduce process is finished and copy the resulting `total_counts.json` to the host machine working directory
		- Delete the docker containers and volume from the host machine
	
*Notice*:
- The steps and code were tested for the Linux Ubuntu distribution from the WSL2 (Windows Subsystem for Linux) and using the Linux computers from the University of Chicago.  I did not test the functionality on a MAC
- In the `count.sh`, I purposefully separated the `run` commands to deploy the containers from the `exec` commands to run the python scripts 
	- I did so to explicitly see the reducer container is waiting for the mapper containers and that even with all containers async, the map-reduce is achieved
	- I am aware there could be a shorter version that achieved the same purpose

# Section 2
**Q: What is the advantage of using Docker for this computation?**
- Mainly: horizontal scalability. This is a task that tends naturally to parallelized computation. Separating the tasks between many dockers can improve the time to achieve the computation
- Coupled with the other benefits mentioned in part 1, this can accelerate the process from development to the final solution

**Q: How did you ensure that the reducer does not start combining results until all mappers have finished their computation? In 1-2 sentences, describe a different method to do this that does not make use of a shared file-system (e.g., if the mappers were all running on different nodes).**
- I ensured by making the `reducer` loop until all the `i.json` files in the `count` folder were created. Since each `i.json` file is created once a `map.py` script finishs counting, the reducer will then sum and save the resulting sum of counts only when all mappers are finished
- To do that using Docker, I created a shared-volume between the containers containing the `counts` folder, so that all containers are saving and looking to the same directory
- An alternative to a shared file-system would be using a messaging system (similar as we did in HW1) 
	- We could make the mappers send a message to the reducer container telling when they are finished with their jobs; the reducer would add the counts as it receives the messages 
	- After all mappers send the message, the reducer container could then finish the sum and copy the result to the host machine

