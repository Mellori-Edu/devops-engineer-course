import boto3
import sys
from libs import ecsservice
global client

def register_task_definition_for_php_service(ecs_task_definition_name, ecs_service_name, ecs_customer,
                                             php_ecs_image, nginx_ecs_image, environment, short_environment,
                                             aws_region, container_port, container_cpu, container_memory,
                                             taskRoleArn, executionRoleArn):
    network_mode = 'awsvpc'

    environment = [
        {
            "name": "ENV",
            "value": "%s" % environment
        }
    ]


    aws_log_group_name = ecs_service_name
    if ecs_service_name == 'backend-fargate':
        aws_log_group_name = 'backend'

    log_configurations = {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/%s" % aws_log_group_name,
            "awslogs-region": aws_region,
            "awslogs-stream-prefix": "ecs"
        }
    }
    mount_points = [
    ]

    volume = [
    ]

    container_definitions = [
        {
            'name': 'nginx',
            'image': nginx_ecs_image,
            # 'cpu': 1024,
            'memoryReservation': 200,
            "logConfiguration": log_configurations,

            'portMappings': [
                {
                    'containerPort': container_port,
                    'hostPort': container_port,
                    'protocol': 'tcp'
                },
            ],
            'essential': True,
            "environment": environment,
            "mountPoints": mount_points,

        },
        {
            'name': 'php',
            'image': php_ecs_image,
            # 'cpu': 1024,
            'memoryReservation': 200,
            "logConfiguration": log_configurations,

            'portMappings': [
            ],
            'essential': True,
            "environment": environment,
            "mountPoints": mount_points
        }
    ]
    response = client.register_task_definition(
        family=ecs_task_definition_name,
        volumes=volume,
        networkMode=network_mode,
        containerDefinitions=container_definitions,
        cpu=container_cpu,
        memory=container_memory,
        requiresCompatibilities=["FARGATE"],
        taskRoleArn=taskRoleArn,
        executionRoleArn=executionRoleArn

    )

    print(response)

    return response


def deploy_service_on_ecs_aws(commit, service_name,
                                  customer, environment, short_environment,
                                  aws_region, cluster_name, ecr_repository_url,
                                  container_memory, container_cpu,
                                  taskRoleArn, executionRoleArn):

    php_ecs_image = '%s/%s-php:%s' % (ecr_repository_url, service_name, commit)
    nginx_ecs_image = '%s/%s-nginx:%s' % (ecr_repository_url, service_name, commit)
    ecs_service_name = '%s-%s' % (service_name, short_environment)

    response = register_task_definition_for_php_service(
        ecs_task_definition_name=ecs_service_name,
        ecs_service_name=ecs_service_name,
        ecs_customer=customer,
        environment=environment,
        short_environment=short_environment,
        aws_region=aws_region,
        container_port=80,
        nginx_ecs_image=nginx_ecs_image,
        php_ecs_image=php_ecs_image,
        container_memory=container_memory,
        container_cpu=container_cpu,
        taskRoleArn=taskRoleArn,
        executionRoleArn=executionRoleArn,
        )

    out_task_definition = response['taskDefinition']['taskDefinitionArn']
    print("Task definition: %s" % out_task_definition)
    print('To start deploy for service %s with commit %s' % (ecs_service_name, commit))
    ecsservice.update_service(client=client, ecs_task_defination=out_task_definition, ecs_service=ecs_service_name,
                   ecs_cluster=cluster_name)
    ecsservice.check_start_deploy(client=client, service_name=ecs_service_name, cluster_name=cluster_name)
    ecsservice.check_finish_deploy(client=client, service_name=ecs_service_name, cluster_name=cluster_name)
    print('To finish_deploy service %s with commit  %s' % (service_name, commit))


if __name__ == '__main__':

    AWS_REGION = 'ap-southeast-1'
    CUSTOMER = 'mycustomer'
    mysession = boto3.session.Session(region_name=AWS_REGION)
    client = mysession.client("ecs")

    meta_data = {
        ('development', 'ecs_cluster_name'): "ecs-demo-cluster",
        ('development', 'ecr_repository_url'): "ACCOUNT_ID.dkr.ecr." + AWS_REGION + ".amazonaws.com",
        ('development', 'container_cpu'): '256',
        ('development', 'container_memory'): '512',
        ('development', 'taskRoleArn'): '',
        ('development', 'executionRoleArn'): 'arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole',
        ('prodution', 'ecs_cluster_name'): "xxx",
        ('prodution', 'ecr_repository_url'): "xxx",
        ('prodution', 'container_cpu'): 512,
        ('prodution', 'container_memory'): 1024,
        ('prodution', 'taskRoleArn'): '',
        ('prodution', 'executionRoleArn'): '',

    }




    service_name = sys.argv[1]
    environment = sys.argv[2]
    commit = sys.argv[3]

    if environment == 'production':
        short_environment = 'prod'
    elif environment == 'development':
        short_environment = 'dev'
    else:
        raise Exception('Environment parameter is not valid')

    ecs_cluster_name = meta_data[(environment, 'ecs_cluster_name')]
    ecr_repository_url = meta_data[(environment, 'ecr_repository_url')]
    container_cpu = meta_data[(environment, 'container_cpu')]
    container_memory = meta_data[(environment, 'container_memory')]
    taskRoleArn = meta_data[(environment, 'taskRoleArn')]
    executionRoleArn = meta_data[(environment, 'executionRoleArn')]
    deploy_service_on_ecs_aws(commit=commit, service_name=service_name, customer=CUSTOMER,
                                  environment=environment, short_environment=short_environment,
                                  aws_region=AWS_REGION, cluster_name=ecs_cluster_name,
                                  ecr_repository_url=ecr_repository_url,
                                  container_cpu=container_cpu, container_memory=container_memory,
                                  taskRoleArn=taskRoleArn, executionRoleArn=executionRoleArn)

