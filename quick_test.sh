#!/usr/bin/env bash

KERNEL=${1:-2} # rbf default
DATA=${2:-a1a}

KERNELS=("linear" "polynomial" "radial basis function" "sigmoid" "precomputed kernel" "asin" "asin_norm" "acos0" "acos1" "acos2")

# if kernel is not a number, then it is a string
if ! [[ "$KERNEL" =~ ^[0-9]+$ ]]; then
    for i in "${!KERNELS[@]}"; do
        if [[ "${KERNELS[$i]}" = "${KERNEL}" ]]; then
            KERNEL=$i
            break
        fi
    done

    if ! [[ "$KERNEL" =~ ^[0-9]+$ ]]; then
        echo "Kernel not found"
        echo "Available kernels: ${KERNELS[*]}"
        exit 1
    fi
fi

KERNEL_NAME="${KERNELS[$KERNEL]}"
echo "Using kernel: ${KERNEL_NAME} ($KERNEL)"

MODEL=${MODEL:-./models/${DATA}-${KERNEL_NAME}.model}

# Other flags passed to svm-train
FLAGS=${@:3}

./svm-train -t "$KERNEL" $FLAGS "./models/${DATA}" "${MODEL}"

echo "Testing model: ${MODEL}"

./svm-predict "./models/${DATA}.t" "${MODEL}" "${MODEL}.out"
