import boto3

def lambda_handler(event, context):

    def stop_start_instances(instance_ids):
        ec2 = boto3.resource('ec2')
        instances = ec2.instances.filter(InstanceIds=instance_ids)

        for instance in instances:
            if instance.state['Name'] == 'running':
                instance.stop()
                print(f"Instance {instance.id} has been stopped.")
            elif instance.state['Name'] == 'stopped':
                instance.start()
                print(f"Instance {instance.id} has been started.")
            else:
                print(f"Instance {instance.id} is in an intermediate state: {instance.state['Name']}. Unable to perform the desired action.")

    # Specify the instance IDs to check and perform actions on
    #instance_ids = ['i-028fb16d1bb7ab61c']
    instance_ids = event["instanceids"];

    # Call the function to stop or start the instances based on their current state
    stop_start_instances(instance_ids)