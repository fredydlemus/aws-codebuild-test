import pytest
from src.app import app

@pytest.fixture
def client():

    with app.test_client() as client:
        yield client

def test_index_route(client):
    """GET / should return a 200 and the correct JSON payload."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data == {"message": "Hello, world!"}