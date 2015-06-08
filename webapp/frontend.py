import os
import requests
from flask import Flask, request, session, g, redirect, url_for, abort, \
	render_template, flash
from flask import send_from_directory
from werkzeug import secure_filename

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/')
def hello_world(name=None):
    name = 'Bob'
    return render_template('hello.html', name=name)

@app.route('/discover')
def discover(entries=None):
	entries = requests.get('http://128.12.10.36:5000/discover').content
	return render_template('discover.html', entries=entries)

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/search', methods=['GET', 'POST'])
def upload_file(filename=None):
    if request.method == 'POST':
        file = request.files['file']
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return redirect(url_for('uploaded_file',
                                    filename=filename))
    return render_template('upload.html',filename=filename)

@app.route('/show/<filename>')
def uploaded_file(filename):
    filename = 'http://127.0.0.1:5001/uploads/' + filename
    if request.method == 'POST':
    	#find results from backend
    	return redirect(url_for('results', searchImg=filename,results=results))
    return render_template('upload.html', filename=filename)

@app.route('/uploads/<filename>')
def send_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@app.route('/results', methods=['GET', 'POST'])
def results(searchImg,results):
    #display results
    # if request.method == 'POST':
    # 	return redirect(url_for('shoepage'))
    return render_template('results.html', searchImg=search,results=results)

@app.route('/shoepage/<filename>', methods=['GET', 'POST'])
def shoepage(shoe=None):
	if request.method == 'POST':
		#find results
		return redirect(url_for('results'), searchImg=shoe.image, results=results)
	return render_template('shoepage.html', shoe)

if __name__ == '__main__':
    app.run(port=5001, debug=True)
