# from flask import Flask
import engine
# app = Flask(__name__)

# @app.route("/api/v1.0/recommendations/<int:id>", methods=["GET"])
# def get_recomendations(id):
#     print("product_id: " + str(id))
#     return engine.get_recommendations(id)

# if __name__ == "__main__":
#     app.run()
    
from flask import Flask, render_template, request
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('test.html')

@app.route('/recommender', methods=['POST'])
def hello():
    first_name = request.form['first_name']
    return engine.get_recommendations(first_name)

if __name__ == '__main__':
    app.run(host="localhost", port=int("7777"))