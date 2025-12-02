package lambdavalida.model;

public class Customer {
    private String cpf;
    private String status;

    public Customer() {}

    public Customer(String cpf, String status) {
        this.cpf = cpf;
        this.status = status;
    }

    public String getCpf() { return cpf; }
    public void setCpf(String cpf) { this.cpf = cpf; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
