from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    name = os.getenv("NAME", "World")
    return f'Hello, {name}!'

if __name__ == '__main__':
    # Run the app on the specified port
    app.run(host='0.0.0.0', port=80)

