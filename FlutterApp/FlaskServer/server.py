from keras.models import model_from_json
import pandas as pd
import librosa
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.utils import shuffle
import pickle
from flask import Flask, request
from flask_cors import CORS, cross_origin
import io

import wave

from werkzeug.datastructures import FileStorage

json_file = open('models/model.json', 'r')
loaded_model_json = json_file.read()
json_file.close()
model = model_from_json(loaded_model_json)
# load weights into new model
model.load_weights("models/Emotion_Voice_Detection_Model.h5")
print("Loaded model from disk")

with open("models/lb.bin", "rb") as lbfile:
    lb: LabelEncoder = pickle.load(lbfile)


def get_emotion(X, sample_rate):
    feeling_list = ['a']
    df2 = pd.DataFrame(columns=['feature'])
    bookmark = 0
    sample_rate = np.array(sample_rate)
    mfccs = np.mean(librosa.feature.mfcc(y=X,
                                         sr=sample_rate,
                                         n_mfcc=13),
                    axis=0)
    feature = mfccs
    # [float(i) for i in feature]
    # feature1=feature[:135]
    df2.loc[bookmark] = [feature]
    bookmark = bookmark + 1

    df3 = pd.DataFrame(df2['feature'].values.tolist())

    labels = pd.DataFrame(feeling_list)
    newdf = pd.concat([df3, labels], axis=1)

    rnewdf = newdf.rename(index=str, columns={"0": "label"})
    rnewdf = shuffle(newdf)
    rnewdf = rnewdf.fillna(0)

    train = rnewdf
    trainfeatures = train.iloc[:, :-1]
    X_train = np.array(trainfeatures)
    x_traincnn = np.expand_dims(X_train, axis=2)
    preds = model.predict(x_traincnn,
                          batch_size=32,
                          verbose=1)
    preds1 = preds.argmax(axis=1)
    abc = preds1.astype(int).flatten()
    predictions = (lb.inverse_transform((abc)))
    ret = predictions[0]
    return ret


app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'


@app.route('/sound', methods=["POST"])
@cross_origin()
def sound():
    print(request)
    # print(request.form)
    pic: FileStorage = request.files.get('sound', FileStorage())

    data = pic.stream.read()
    pic.stream.close()

    bio = io.BytesIO()
    with wave.open(bio, 'wb') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(44100)
        wav.writeframesraw(data)

    bio.seek(0)

    x, sample_rate = librosa.load(bio, res_type='kaiser_fast', duration=2.5, sr=22050 * 2, offset=0.5)

    rsp = get_emotion(x, sample_rate)

    print(str(rsp))
    return str(rsp)


if __name__ == '__main__':
    app.run(host="192.168.43.132", port=8080)
