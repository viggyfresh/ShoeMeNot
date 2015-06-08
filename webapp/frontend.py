import os
import requests
from flask import Flask, request, session, g, redirect, url_for, abort, \
	render_template, flash
from flask import send_from_directory
from werkzeug import secure_filename
import json

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
	j = json.loads(requests.get(ip + 'discover').content)
        entries = j["data"]
	return render_template('discover.html', ip=ip, entries=entries)

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/search', methods=['GET', 'POST'])
def upload_file(filename=None):
    if request.method == 'POST':
        return redirect(url_for('results'))
        # file = request.files['file']
        # if file and allowed_file(file.filename):
        #     filename = secure_filename(file.filename)
        #     file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        #     return redirect(url_for('uploaded_file',
        #                             filename=filename))
    return render_template('upload.html',filename=filename,ip=ip)

@app.route('/show/<filename>')
def uploaded_file(filename):
    filename = 'http://127.0.0.1:5001/uploads/' + filename
    if request.method == 'POST':
    	return redirect(url_for('results'))
    return render_template('upload.html', filename=filename, ip=ip)

@app.route('/uploads/<filename>')
def send_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@app.route('/results', methods=['GET', 'POST'])
def results(searchImg,results):
    j = json.loads(requests.get(ip + 'upload').content)
    results = j["data"]
    return render_template('results.html', searchImg=searchImg,results=results)

@app.route('/shoepage/<shoeid>', methods=['GET', 'POST'])
def shoepage(shoeid):
    shoeinfo = json.loads(requests.get(ip + 'shoe/' + shoeid).content)
    if request.method == 'POST':
	   return redirect(url_for('results'), searchImg=shoeid)
    return render_template('shoepage.html',shoeinfo=shoeinfo,shoeid=shoeid,ip=ip)

if __name__ == '__main__':
    app.run(port=5001, debug=True)
