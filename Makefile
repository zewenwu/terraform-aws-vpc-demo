# CI linting and formatting
lint:
	tflint --format default --recursive
	terraform fmt -check -recursive

format:
	terraform fmt -recursive