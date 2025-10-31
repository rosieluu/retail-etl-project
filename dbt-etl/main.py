from fastapi import FastAPI, HTTPException
from typing import Optional
import subprocess
import logging
# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "DBT Runner API is running"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}


@app.get("/run")
def run_dbt():
    logger.info("Running dbt run command")

    # Run the dbt run command and capture the output
    result = subprocess.run(["dbt", "run"], capture_output=True, text=True)

    # Check the return code of the command
    if result.returncode == 0:
        # The command succeeded
        logger.info("dbt run command succeeded")
        logger.info("dbt run output: " + result.stdout)
        logger.info("dbt run error: " + result.stderr)
        return {"output": result.stdout, "error": result.stderr}
    else:
        # The command failed
        error_message = f"dbt run command failed with error: {result.stderr} stdout: {result.stdout}"
        logger.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)


@app.get("/get/test")
def run_then_test_dbt(
    model: Optional[str] = None,
    test_type: Optional[str] = None,
    verbose: bool = False,
):
    """Run `dbt run` then `dbt test` with optional filters.

    Query params:
      - model: run tests for a specific model name (e.g. dim_customer)
      - test_type: one of ['schema', 'custom', 'all'] to run schema-only, custom-only or all tests
      - verbose: if true, pass --verbose to dbt test

    Examples:
      /get/test -> runs all tests after dbt run
      /get/test?model=dim_customer -> runs tests for dim_customer
      /get/test?test_type=schema -> runs schema tests only
      /get/test?test_type=custom -> runs custom tests only
      /get/test?verbose=true -> runs tests with --verbose
    """
    logger.info("Running dbt run before dbt test")

    # Run dbt run first
    run_result = subprocess.run(["dbt", "run"], capture_output=True, text=True)
    logger.info("dbt run returncode: %s", run_result.returncode)
    logger.info("dbt run stdout: %s", run_result.stdout)
    logger.info("dbt run stderr: %s", run_result.stderr)

    if run_result.returncode != 0:
        error_message = f"dbt run failed: {run_result.stderr} stdout: {run_result.stdout}"
        logger.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)

    # Build dbt test command according to query params
    test_cmd = ["dbt", "test"]

    if model:
        # run tests for a specific model
        test_cmd.extend(["--models", model])
    elif test_type:
        tt = test_type.lower()
        if tt == "schema":
            test_cmd.extend(["--models", "test_type:schema"])
        elif tt in ("custom", "generic"):
            test_cmd.extend(["--models", "test_type:generic"])
        elif tt == "all":
            # no additional args
            pass
        else:
            raise HTTPException(status_code=400, detail=f"Unknown test_type: {test_type}")

    if verbose:
        test_cmd.append("--verbose")

    logger.info("Running dbt test command: %s", " ".join(test_cmd))
    test_result = subprocess.run(test_cmd, capture_output=True, text=True)
    logger.info("dbt test returncode: %s", test_result.returncode)
    logger.info("dbt test stdout: %s", test_result.stdout)
    logger.info("dbt test stderr: %s", test_result.stderr)

    if test_result.returncode == 0:
        return {
            "run_output": run_result.stdout,
            "run_error": run_result.stderr,
            "test_command": " ".join(test_cmd),
            "test_output": test_result.stdout,
            "test_error": test_result.stderr,
        }
    else:
        error_message = f"dbt test failed: {test_result.stderr} stdout: {test_result.stdout}"
        logger.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)


# @app.post("/run-dbt")
# async def run_dbt_command(command: str):
#     """
#     Endpoint to run a dbt command.
#     :param command: The dbt command to run (e.g., "dbt run", "dbt test").
#     :return: The output of the dbt command or an error message.
#     """
#     try:
#         logger.info(f"Running dbt command: {command}")
#         result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
#         logger.info("dbt command executed successfully.")
#         return {"output": result.stdout}
#     except subprocess.CalledProcessError as e:
#         logger.error(f"Error running dbt command: {e.stderr}")
#         raise HTTPException(status_code=500, detail=f"Error running dbt command: {e.stderr}")