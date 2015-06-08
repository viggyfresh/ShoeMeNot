import os
from flask import Flask, request, session, g, redirect, url_for, abort, \
	render_template, flash
#from flask.ext.navigation import Navigation

app = Flask(__name__)
#nav = Navigation(app)

# nav.Bar('top', [
#     nav.Item('Home', 'hello_world'),
#     #nav.Item('Discover', 'news', {'page': 1}),
# ])

@app.route('/')
def hello_world(name=None):
    name = 'Bob'
    return render_template('hello.html', name=name)

@app.route('/discover')
def discover():
    test = "testing"
    return render_template('discover.html', test=test)

# @app.route('/search', methods=['GET', 'POST'])
# def search():
#     if request.method == 'POST':
#     	#find results and send to results page
#     	return redirect(url_for('results'))
#     return render_template('search.html')

# @app.route('/results', methods=['GET', 'POST'])
# def results():
#     #display results
#     if request.method == 'POST':
#     	#find results and send to results page
#     	return redirect(url_for('shoepage'))
#     return render_template('results.html', shoes)

# @app.route('/shoepage', methods=['GET', 'POST'])
# def shoepage():
#     #get shoe information
#     if request.method == 'POST':
#     	#link to shoe page
#     return render_template('shoepage.html', shoe)

if __name__ == '__main__':
    app.run(port=5001, debug=True)
