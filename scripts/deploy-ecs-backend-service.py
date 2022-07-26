import boto3
import sys
from libs import ecsservice

def register_task_definition_for_php_service(ecs_task_definition_name, ecs_service_name, ecs_customer,
                                             php_ecs_image, nginx_ecs_image, environment, short_environment,
                                             aws_region, container_port):
    network_mode = 'bridge'

    log_configurations = {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/%s" % ecs_service_name,
            "awslogs-region": aws_region,
            "awslogs-stream-prefix": "ecs"
        }
    }


    container_definitions = [
        {
            'name': 'nginx',
            'image': nginx_ecs_image,
            'memoryReservation': 50,
            'hostname': 'nginx-%s-%s-%s' % (ecs_service_name, ecs_customer, short_environment),
            "logConfiguration": log_configurations,
            "links": [
                "php"
            ],

            'portMappings': [
                {
                    'containerPort': container_port,
                    'hostPort': 0,
                    'protocol': 'tcp'
                },
            ],
            'essential': True

        },
        {
            'name': 'php',
            'image': php_ecs_image,
            'memoryReservation': 50,
            'hostname': 'php-%s-%s-%s' % (ecs_customer, short_environment, ecs_service_name),
            "logConfiguration": log_configurations,

            'portMappings': [
            ],
            'essential': True,
            "environment": [{
                "name": "ENV",
                "value": "%s" % environment
            }]
        }
    ]


    response = client.register_task_definition(
        family=ecs_task_definition_name,
        volumes=[],
        networkMode=network_mode,
        containerDefinitions=container_definitions

    )

    return response


def deploy_service_on_ecs_aws(commit, service_name,
                                  customer, environment, short_environment,
                                  aws_region, cluster_name, ecr_repository_url):

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
        php_ecs_image=php_ecs_image)

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

    meta_data = {
        ('development', 'ecs_cluster_name'): "ecs-demo-cluster",
        ('development', 'ecr_repository_url'): "813995029960.dkr.ecr." + AWS_REGION + ".amazonaws.com",
        ('production', 'ecs_cluster_name'): "xxx",
        ('production', 'ecr_repository_url'): "xxx",

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


    global client
    mysession = boto3.session.Session(region_name=AWS_REGION)
    client = mysession.client("ecs")

    ecs_cluster_name = meta_data[(environment, 'ecs_cluster_name')]
    ecr_repository_url = meta_data[(environment, 'ecr_repository_url')]
    deploy_service_on_ecs_aws(commit=commit, service_name=service_name, customer=CUSTOMER,
                                  environment=environment, short_environment=short_environment,
                                  aws_region=AWS_REGION, cluster_name=ecs_cluster_name,
                                  ecr_repository_url=ecr_repository_url)

