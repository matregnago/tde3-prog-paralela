#include <iostream>
#include <cuda.h>

// Kernel para somar dois vetores
__global__ void somaVetores(int *a, int *b, int *c, int n) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    int n = 100;
    int size = n * sizeof(int);

    // Aloca memória no host
    int *h_a = (int *)malloc(size);
    int *h_b = (int *)malloc(size);
    int *h_c = (int *)malloc(size);

    // Inicializa os vetores a e b no host
    for (int i = 0; i < n; i++) {
        h_a[i] = i;
        h_b[i] = i * 2;
    }

    // Aloca memória no device
    int *d_a, *d_b, *d_c;
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    // Copia os dados do host para o device
    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

    // Define o número de threads e blocos
    int threadsPerBlock = 256;
    int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;

    // Executa o kernel
    somaVetores<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, n);

    // Copia o resultado do device para o host
    cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);

    // Exibe o resultado
    std::cout << "Resultado da soma:\n";
    for (int i = 0; i < n; i++) {
        std::cout << h_c[i] << " ";
    }
    std::cout << "\n";

    // Libera a memória
    free(h_a);
    free(h_b);
    free(h_c);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}
