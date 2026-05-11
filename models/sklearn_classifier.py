import typing
import numpy as np

from sklearn.ensemble import RandomForestClassifier, IsolationForest
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

MODELS_FACTORY = {
    "RandomForestClassifier": RandomForestClassifier,
    "IsolationForest": IsolationForest # <--- ADICIONAMOS AQUI
}

class SklearnClassifier():
    def __init__(self, model_hyperparams: typing.Dict):
        super(SklearnClassifier, self).__init__()
        self._model_name = model_hyperparams["model_name"]
        self._model_params = model_hyperparams["model_params"]

        if self._model_name not in MODELS_FACTORY:
            raise KeyError(f"Selected model {self._model_name} is NOT available!")

        pipeline_steps = [
            ('scaler', StandardScaler()),
            ('clf', MODELS_FACTORY[self._model_name](**self._model_params))
        ]

        self._model = Pipeline(pipeline_steps)

    def reset(self):
        self._model = MODELS_FACTORY[self._model_name](**self._model_params)

    def train(self, X_data, y_data=None): # y_data é opcional, pois IF não usa no treino
        # Isolation Forest ignora o y_data por ser não-supervisionado
        if self._model_name == "IsolationForest":
            self._model = self._model.fit(X_data)
        else:
            self._model = self._model.fit(X_data, y_data)

    def predict(self, X_data):
        y_pred = self._model.predict(X_data)
        
        # TRADUTOR DO ISOLATION FOREST
        # O Isolation Forest retorna 1 para Normal (Inlier) e -1 para Anomalia (Outlier)
        # O resto da arquitetura espera 0 para Normal e 1 para Ataque
        if self._model_name == "IsolationForest":
            # Converte: 1 -> 0 (Normal) e -1 -> 1 (Ataque)
            y_pred = np.where(y_pred == 1, 0, 1)

        return y_pred

    def predict_proba(self, X_data):
        # Isolation Forest não tem probabilidade direta (predict_proba).
        # Vamos usar a função decision_function (score de anomalia) e normalizar entre 0 e 1.
        if self._model_name == "IsolationForest":
            scores = self._model.decision_function(X_data)
            # Scores muito negativos são anomalias (Ataque), positivos são normais
            # Invertemos para simular probabilidade de ser ataque
            probs = 1 - (1 / (1 + np.exp(-scores))) 
            # Criamos o formato [prob_normal, prob_ataque] esperado pelo pipeline
            return np.vstack([1 - probs, probs]).T
        else:
            return self._model.predict_proba(X_data)