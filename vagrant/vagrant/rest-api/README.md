# How to use:

1. Go to the 'app' directory
2. Depending on which VM you're in, go to the corresponding directory. For example, if you're in the 'CPE' directory, then go to 'cpe' directory.
3. Then run the following command.
```
sudo python -m pipenv run uvicorn main:app --host 0.0.0.0 --port 8000
```