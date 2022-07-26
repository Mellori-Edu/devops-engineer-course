def update_service(client, ecs_task_defination, ecs_service, ecs_cluster):
    response = client.update_service(
        cluster=ecs_cluster,
        service=ecs_service,
        taskDefinition=ecs_task_defination,
    )
    return response


def describe_service(client, service_name, cluster_name):
    response = client.describe_services(
        cluster=cluster_name,
        services=[
            service_name,
        ]
    )
    return response


def check_finish_deploy_by_event(service_info, service_name):
    events = service_info['events']
    end_message = events[0]
    # for item in events:
    #     logger.debug(item)
    if end_message['message'] == '(service %s) has reached a steady state.' % service_name:
        return True
    return False


def check_finish_deploy_by_deployment(client, service_name, cluster_name):
    import time
    for row in range(0, 100):
        response = describe_service(client=client, service_name=service_name, cluster_name=cluster_name)
        service_info = response['services'][0]
        if len(service_info['deployments']) == 1:
            return True
        time.sleep(15)


def check_start_deploy(client, service_name, cluster_name):
    import time
    for row in range(0, 100):
        response = describe_service(client=client, service_name=service_name, cluster_name=cluster_name)
        service_info = response['services'][0]
        if len(service_info['deployments']) >= 1:
            break
        time.sleep(15)


def check_finish_deploy(client, service_name, cluster_name):
    import time
    for row in range(0, 100):
        response = describe_service(client=client, service_name=service_name, cluster_name=cluster_name)
        service_info = response['services'][0]
        if check_finish_deploy_by_event(service_name=service_name, service_info=service_info):
            # print('receive finish event')
            if check_finish_deploy_by_deployment(client=client, service_name=service_name, cluster_name=cluster_name):
                # print('only one task in deployments')
                break
        time.sleep(10)