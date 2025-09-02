from flask import render_template, request, redirect, url_for, g, Blueprint

bp = Blueprint('main', __name__)

@bp.route('/')
def home():
    return render_template('index.html')

@bp.route('/submit', methods=['POST'])
def submit():
    name = request.form.get('name')
    email = request.form.get('email')
    if name and email:
        g.cursor.execute("INSERT INTO Students (name, email) VALUES (?, ?)", (name, email))
        g.conn.commit()
    return redirect(url_for('main.show_entries'))

@bp.route('/entries')
def show_entries():
    g.cursor.execute("SELECT StudentID, name, email FROM Students")
    result = g.cursor.fetchall()
    return render_template('entries.html', entries=result)
