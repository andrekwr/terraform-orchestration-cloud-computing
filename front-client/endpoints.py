import requests
import click

#Don't change lb_host variable, terraform will do it for you. If you do, errors may occurs.
lb_host="terraform-backend-elb-771735597.us-east-1.elb.amazonaws.com"

@click.command()
def help():
    """Lists endpoints"""
    click.echo('gettasks: Get all tasks from database')
    click.echo('gettask: Get specific task from database')
    click.echo('createtask: Create an task')
    click.echo('deletetask: Delete specific task from database')
    click.echo('deletetasks: Delete all tasks from database')
    click.echo('Use <command> --help for more informations')

@click.command()
def GetAllTasks():
    """Get all tasks from database"""
    response = requests.get('http://'+ lb_host +':8080/tasks/list')
    click.echo(response.json())

@click.option('--id', prompt='Task id', help='Select an specific task using its id.')
@click.command()
def GetOneTask(id):
    """Get specific task from database"""
    response = requests.get('http://'+ lb_host +':8080/tasks/list/'+ id)
    click.echo(response.json())

@click.option('--pub_date', prompt='Published date', help='Date of publication')
@click.option('--description', prompt='Description', help='Task`s description', default='No description.')
@click.option('--title', prompt='Title', help='The title of the task.')
@click.command()
def CreateATask(title, pub_date, description):
    """Create an task"""
    data = {'title': title, 'pub_date': pub_date, 'description': description}
    response = requests.post('http://'+ lb_host +':8080/tasks/create', data=data)
    if response.status_code == 201:
        click.echo('Task successfully created.')
        click.echo(response.json())
    else:
        click.echo('Fail to create task. Verify your data.')
    
@click.option('--id', prompt='Task id', help='Delete an specific task using its id.')
@click.command()
def DeleteOneTask(id):
    """Delete specific task from database"""
    response = requests.delete('http://'+ lb_host +':8080/tasks/delete/'+ id)
    click.echo(response.text)

@click.command()
def DeleteAllTasks():
    """Delete all tasks from database"""
    response = requests.delete('http://'+ lb_host +':8080/tasks/delete')
    click.echo(response.text)

