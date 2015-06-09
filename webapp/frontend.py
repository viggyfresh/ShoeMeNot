import os
import requests
from flask import Flask, request, session, g, redirect, url_for, abort, \
	render_template, flash, jsonify
from flask import send_from_directory, make_response
from werkzeug import secure_filename
import json
from array import array

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
ip = 'http://128.12.10.36:5000/'

@app.route('/')
def hello_world(name=None):
    return redirect("/discover")

@app.route('/discover')
def discover(entries=None):
	j = requests.get(ip + 'discover').json()
        entries = j["data"]
	return render_template('discover.html', ip=ip, entries=entries)

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/upload', methods=['POST'])
def upload_to_server():
    if request.method == 'POST':
        file = request.files['file'].read()
        data = {"file": file}
        j = requests.request('POST', ip + 'upload', files=data).json()
        upload_url = ip + 'static/uploads/' + j['id'] + '.jpg'
        results = j['data']
        return render_template('results.html', ip=ip, shoeURL=upload_url, results=results)

@app.route('/search')
def upload_file():
    return render_template('upload.html', ip=ip)

@app.route('/compare/<id>')
def compare(id):
    j = requests.get(ip + 'compare/' + id).json()
    url = ip + 'static/shoe_dataset/' + id + '.jpg'
    results = j['data']
    return render_template('results.html', ip=ip, shoeURL=url, results=results)

@app.route('/shoepage/<shoeid>', methods=['GET', 'POST'])
def shoepage(shoeid):
    shoeinfo = json.loads(requests.get(ip + 'shoe/' + shoeid).content)
    data = get_saved_data()
    if request.method == 'POST':
	   return redirect(url_for('results'), searchImg=shoeid)
    return render_template('shoepage.html',shoeinfo=shoeinfo,shoeid=shoeid,ip=ip,favorites=data)

@app.route('/favorites')
def favorites():
    data = get_saved_data()
    return render_template('favorites.html', favorites=data, ip=ip)

@app.route('/save_favorite/<shoeid>', methods=['GET', 'POST'])
def save_favorite(shoeid):
    response = make_response(redirect('/shoepage/' + shoeid))
    data = get_saved_data()
    data.append(shoeid)
    j = json.dumps({"favorites": data})
    response.set_cookie('favorites', j)
    return response

@app.route('/remove_favorite/<shoeid>', methods=['GET', 'POST'])
def remove_favorite(shoeid):
    response = make_response(redirect('/shoepage/' + shoeid))
    data = get_saved_data()
    data.remove(shoeid)
    j = json.dumps({"favorites": data})
    response.set_cookie('favorites', j)
    return response

def get_saved_data():
    try:
        j = json.loads(request.cookies.get('favorites'))
        data = j["favorites"]
    except TypeError:
        data = []
    return data

if __name__ == '__main__':
    app.run(port=5001, debug=True)
