
import argparse
import subprocess
from pathlib import Path


def minimize_sdf(input_file, output_file, steps, forcefield):
    command = [
        "obabel",
        str(input_file),
        "-O", str(output_file),
        "--minimize",
        "--ff", forcefield,
        "--steps", str(steps)
    ]

    result = subprocess.run(
        command,
        capture_output=True,
        text=True
    )

    if result.returncode == 0 and output_file.exists() and output_file.stat().st_size > 0:
        return True, result.stderr

    return False, result.stderr


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--steps", type=int, default=20000)
    parser.add_argument("--ff", default="MMFF94")

    args = parser.parse_args()

    input_dir = Path(args.input)
    output_dir = Path(args.output)

    output_dir.mkdir(parents=True, exist_ok=True)

    sdf_files = sorted(input_dir.glob("*.sdf"))

    print(f"Total SDF files: {len(sdf_files)}")

    successful = 0
    failed = 0

    with open(output_dir / "minimization_log.txt", "w") as log:

        for i, sdf_file in enumerate(sdf_files, 1):
            output_file = output_dir / sdf_file.name

            success, error = minimize_sdf(
                sdf_file,
                output_file,
                args.steps,
                args.ff
            )

            if success:
                successful += 1
                status = "SUCCESS"
            else:
                failed += 1
                status = "FAILED"

            message = f"[{i}/{len(sdf_files)}] {sdf_file.name}: {status}"

            print(message)
            log.write(message + "\n")

            if error:
                log.write(error + "\n")

    print("\nMinimization completed.")
    print(f"Successful: {successful}")
    print(f"Failed: {failed}")


if __name__ == "__main__":
    main()
