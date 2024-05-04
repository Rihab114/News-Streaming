provider "aws" {
  region = "eu-west-3"
  profile = "default"
}

#create a vpc
resource "aws_vpc" "kafka-project-vpc" {
  cidr_block = "10.0.0.0/16"
}

#create a subnet within the vpc 
resource "aws_subnet" "kafka-project-subnet" {
  vpc_id = aws_vpc.kafka-project-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-3a"
}

#Create a security group 
resource "aws_security_group" "kafka-project-sg" {
  vpc_id = aws_vpc.kafka-project-vpc.id
  
  //Inbound rule to allow SSH access 
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  //Outbound rule to allow all traffic 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

}
}
#Create a key pair for SSH access 
resource "aws_key_pair" "kafka-project-kp" {
  key_name = "kafka-project-kp"
  public_key = file("./id_rsa.pub")
}
#Create and EC2 instance 
resource "aws_instance" "kafka-instance" {
  ami = "ami-0ebc281c20e89ba4b"
  instance_type ="t2.micro"
  subnet_id = aws_subnet.kafka-project-subnet.id
  key_name = aws_key_pair.kafka-project-kp.key_name
  
  tags = {
    Name = "kafka-instance"

}
}
#OUtput the private IP and access key to connect to te instance
output "instance_id_and_key" {
  value = "To connect to the instance, use the following command:\nssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.kafka-instance.private_ip}"
}
