from setuptools import setup

setup(
    name = 'front',
    version = '0.1',
    install_requires = ['Click',],
    py_modules = ['endpoints'],
    entry_points= '''
    [console_scripts]
    hello=endpoints:hello
    signup=endpoints:SignUp
    login=endpoints:Login
    refreshtoken=endpoints:RefreshToken
    gettasks=endpoints:GetAllTasks
    gettask=endpoints:GetOneTask
    createtask=endpoints:CreateATask
    deletetask=endpoints:DeleteOneTask
    deletetasks=endpoints:DeleteAllTasks
    _help=endpoints:help
    '''
)