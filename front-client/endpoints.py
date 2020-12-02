import requests
import click

#Don't change lb_host variable, terraform will do it for you. If you do, errors may occurs.
lb_host="terraform-backend-elb-2106664098.us-east-1.elb.amazonaws.com"

@click.command()
def help():
    """Lists endpoints"""
    click.echo('signup: SignUp to app')
    click.echo('login: Login into app')
    click.echo('refreshtoken: Refresh your Jwt token')
    click.echo('gettasks: Get all tasks from database')
    click.echo('gettask: Get specific task from database')
    click.echo('createtask: Create an task')
    click.echo('deletetask: Delete specific task from database')
    click.echo('deletetasks: Delete all tasks from database')
    click.echo('Use <command> --help for more informations')

@click.option('--token', prompt='token', help='Insert your token')
@click.command()
def GetAllTasks(token):
    """Get all tasks from database"""
    response = requests.get('http://'+ lb_host +':8080/tasks/list', headers={'Authorization': 'jwt ' + token})
    click.echo(response.json())

@click.option('--id_', prompt='Task id', help='Select an specific task using its id.')
@click.option('--token', prompt='token', help='Insert your token')
@click.command()
def GetOneTask(id_, token):
    """Get specific task from database"""
    response = requests.get('http://'+ lb_host +':8080/tasks/list/'+ id_, headers={'Authorization': 'jwt ' + token})
    click.echo(response.json())

@click.option('--pub_date', prompt='Published date', help='Date of publication')
@click.option('--description', prompt='Description', help='Task`s description', default='No description.')
@click.option('--title', prompt='Title', help='The title of the task.')
@click.option('--token', prompt='token', help='Insert your token')
@click.command()
def CreateATask(title, pub_date, description, token):
    """Create an task"""
    data = {'title': title, 'pub_date': pub_date, 'description': description}
    response = requests.post('http://'+ lb_host +':8080/tasks/create', data=data, headers={'Authorization': 'jwt ' + token})
    if response.status_code == 201:
        click.echo('Task successfully created.')
        click.echo(response.json())
    else:
        click.echo('Fail to create task. Verify your data.')


@click.option('--password2', prompt='Confirm Password', help='Confirm your password', hide_input=True)
@click.option('--password1', prompt='Password', help='Password (must be 8 characters long, one capital letter, at least one number, at least one special character)', hide_input=True)
@click.option('--username', prompt='Username', help='Username')
@click.command()
def SignUp(username, password1, password2):
    """Register a User"""
    data = {'username': username, 'password1': password1, 'password2': password2}
    response = requests.post('http://'+ lb_host +':8080/auth/signup/', data=data)
    if response.status_code == 201:
        click.echo('User successfully registered.')
        click.echo(response.json())
    else:
        click.echo('Fail to register user. Verify your data.')
        click.echo(response)


@click.option('--password', prompt='Password', help='Password', hide_input=True)
@click.option('--username', prompt='Username', help='Username')
@click.command()
def Login(username, password):
    """Login"""
    global token
    data = {'username': username, 'password': password}
    response = requests.post('http://'+ lb_host +':8080/auth/login/', data=data)
    if response.status_code == 200:
        click.echo('User successfully logged in.')
        click.echo(response.json())
    else:
        click.echo('Fail to login. Verify your data.')
        click.echo(response)

@click.option('--token', prompt='Jwt token', help='Your jwt token caught via login/signup')
@click.command()
def RefreshToken(token):
    """Refresh jwt Token"""
    data = {'token': token}
    response = requests.post('http://'+ lb_host +':8080/auth/refresh-token/', data=data)
    if response.status_code == 200:
        click.echo('Token successfully refreshed.')
        click.echo(response.json())
    else:
        click.echo('Fail to refresh. Verify your token.')
        click.echo(response)

@click.option('--id_', prompt='Task id', help='Delete an specific task using its id.')
@click.option('--token', prompt='token', help='Insert your token')
@click.command()
def DeleteOneTask(id_, token):
    """Delete specific task from database"""
    response = requests.delete('http://'+ lb_host +':8080/tasks/delete/'+ id_, headers={'Authorization': 'jwt ' + token})
    click.echo(response.text)

@click.option('--token', prompt='token', help='Insert your token')
@click.command()
def DeleteAllTasks(token):
    """Delete all tasks from database"""
    response = requests.delete('http://'+ lb_host +':8080/tasks/delete', headers={'Authorization': 'jwt ' + token})
    click.echo(response.text)

