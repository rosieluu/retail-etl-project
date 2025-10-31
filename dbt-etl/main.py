from fastapi import FastAPI, HTTPException
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


@app.get("/test")
def run_test_dbt():
    
    # If run succeeded, execute dbt test
    logger.info("Running dbt test command")
    test_result = subprocess.run(["dbt", "test"], capture_output=True, text=True)
    logger.info("dbt test returncode: %s", test_result.returncode)
    logger.info("dbt test stdout: %s", test_result.stdout)
    logger.info("dbt test stderr: %s", test_result.stderr)

    if test_result.returncode == 0:
        return {
            "run_output": run_result.stdout,
            "run_error": run_result.stderr,
            "test_output": test_result.stdout,
            "test_error": test_result.stderr,
        }
    else:
        error_message = f"dbt test failed: {test_result.stderr} stdout: {test_result.stdout}"
        logger.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)


@app.get("/snapshot")
def run_dbt_snapshot():
    """Run dbt snapshot to capture historical changes."""
    logger.info("Running dbt snapshot command")

    # Run the dbt snapshot command and capture the output
    result = subprocess.run(["dbt", "snapshot"], capture_output=True, text=True)

    # Check the return code of the command
    if result.returncode == 0:
        # The command succeeded
        logger.info("dbt snapshot command succeeded")
        logger.info("dbt snapshot output: " + result.stdout)
        logger.info("dbt snapshot error: " + result.stderr)
        return {"output": result.stdout, "error": result.stderr}
    else:
        # The command failed
        error_message = f"dbt snapshot command failed with error: {result.stderr} stdout: {result.stdout}"
        logger.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)


@app.get("/full-pipeline")
def run_full_pipeline():
    """Run complete pipeline: dbt run -> dbt snapshot -> dbt test."""
    logger.info("Running full dbt pipeline")

    # Step 1: dbt run
    run_result = subprocess.run(["dbt", "run"], capture_output=True, text=True)
    logger.info("dbt run returncode: %s", run_result.returncode)
    
    if run_result.returncode != 0:
        error_message = f"dbt run failed: {run_result.stderr} stdout: {run_result.stdout}"
        logger.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)

    # Step 2: dbt snapshot
    snapshot_result = subprocess.run(["dbt", "snapshot"], capture_output=True, text=True)
    logger.info("dbt snapshot returncode: %s", snapshot_result.returncode)
    
    if snapshot_result.returncode != 0:
        error_message = f"dbt snapshot failed: {snapshot_result.stderr} stdout: {snapshot_result.stdout}"
        logger.error(error_message)
        raise HTTPException(status_code=500, detail=error_message)

    # Step 3: dbt test
    test_result = subprocess.run(["dbt", "test"], capture_output=True, text=True)
    logger.info("dbt test returncode: %s", test_result.returncode)
    
    if test_result.returncode == 0:
        return {
            "run_output": run_result.stdout,
            "run_error": run_result.stderr,
            "snapshot_output": snapshot_result.stdout,
            "snapshot_error": snapshot_result.stderr,
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