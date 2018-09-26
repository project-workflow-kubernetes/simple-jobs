PROJECT_NAME=job
TEST_PATH=./


help:
	@echo "install - install project in dev mode using conda"
	@echo "test -  run tests quickly within env: $(PROJECT_NAME)"
	@echo "lint - check code style"
	@echo "clean - remove build and python artifacts"
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove python artifacts"
	@echo
	@echo "preprocessing - generates clean_train.csv, clean_test.csv"
	@echo "split - generates y_train.csv, X_train.csv, y_val, X_val"
	@echo "train - generates trained_model.pkl"
	@echo "score-test - generates score_test.csv"


test: clean-pyc
	@echo "\n--- If the env $(PROJECT_NAME) doesn't exist, run 'make install' before ---\n"n
	@echo "\n--- Running tests at $(PROJECT_NAME) ---\n"
	bash -c "source activate $(PROJECT_NAME) &&  py.test --verbose --color=yes $(TEST_PATH)"


test-in-docker:
	@echo "\n--- Make sure that your docker-machine is up ---\n"
	@echo "\n--- Building docker ---\n"
	@docker build -t test-$(PROJECT_NAME) .
	@echo "\n--- Running tests inside docker ---\n"
	-@docker run test-$(PROJECT_NAME) py.test --verbose --color=yes
	@docker rmi -f test-$(PROJECT_NAME)


install: clean
	-@conda env remove -yq -n $(PROJECT_NAME) # ignore if fails
	@conda create -y --name $(PROJECT_NAME) --file conda.txt
	@echo "\n --- Creating env: $(PROJECT_NAME) in $(shell which conda) ---\n"
	@echo "\n--- Installing dependencies ---\n"
	bash -c "source activate $(PROJECT_NAME) && pip install -e . && pip install -U -r requirements.txt && source deactivate"


lint:
	-@pylint src/**/*.py --output-format text --reports no --msg-template "{path}:{line:04d}:{obj} {msg} ({msg_id})" | sort


clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +


clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +


clean: clean-build clean-pyc


preprocessing: resources/train.csv resources/test.csv
	@echo "\n--- If the env $(PROJECT_NAME) doesn't exist, run 'make install' before ---\n"
	bash -c "source activate $(PROJECT_NAME)"
	@echo "\n--- Running preprocessing.py file ---\n"
	python src/$(PROJECT_NAME)/preprocessing.py


split: resources/clean_train.csv
	@echo "\n--- If the env $(PROJECT_NAME) doesn't exist, run 'make install' before ---\n"
	bash -c "source activate $(PROJECT_NAME)"
	@echo "\n--- Running split.py file ---\n"
	python src/$(PROJECT_NAME)/split.py


train: resources/X_train.csv resources/X_val.csv resources/y_train.csv resources/y_val.csv
	@echo "\n--- If the env $(PROJECT_NAME) doesn't exist, run 'make install' before ---\n"
	bash -c "source activate $(PROJECT_NAME)"
	@echo "\n--- Running train.py file ---\n"
	python src/$(PROJECT_NAME)/train.py


score-test: resources/clean_test.csv resources/trained_model.pkl
	@echo "\n--- If the env $(PROJECT_NAME) doesn't exist, run 'make install' before ---\n"
	bash -c "source activate $(PROJECT_NAME)"
	@echo "\n--- Running main.py file ---\n"
	python src/$(PROJECT_NAME)/score_test.py
