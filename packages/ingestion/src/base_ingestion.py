from abc import ABC, abstractmethod


class BaseIngestion(ABC):
    """共通インターフェースを持つIngestion基底クラス。"""

    @abstractmethod
    def extract(self):
        raise NotImplementedError

    @abstractmethod
    def transform(self, records):
        raise NotImplementedError

    @abstractmethod
    def load(self, records):
        raise NotImplementedError

    def run(self):
        records = self.extract()
        records = self.transform(records)
        self.load(records)
