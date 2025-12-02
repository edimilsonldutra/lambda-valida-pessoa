package lambdavalida.service;

import lambdavalida.model.Customer;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

/**
 * Service to manage customer data in PostgreSQL (RDS)
 */
public class CustomerService {

    private final String dbUrl;
    private final String dbUser;
    private final String dbPassword;
    private final String schema;
    private final String table;
    private final boolean dbEnabled;

    public CustomerService() {
        // Load DB credentials from Secrets Manager
        String secretArn = System.getenv().getOrDefault("DB_SECRET_ARN", "");
        if (secretArn == null || secretArn.isEmpty()) {
            throw new IllegalStateException("DB_SECRET_ARN environment variable is required");
        }

        Region region = Region.of(System.getenv().getOrDefault("AWS_REGION", System.getenv().getOrDefault("AWS_DEFAULT_REGION", "us-east-1")));
        SecretsManagerClient client = SecretsManagerClient.builder().region(region).build();
        GetSecretValueResponse secretValue = client.getSecretValue(GetSecretValueRequest.builder().secretId(secretArn).build());

        Map<String, Object> secret = JsonUtils.parseJsonToMap(secretValue.secretString());
        String host = (String) secret.getOrDefault("host", secret.getOrDefault("hostname", ""));
        int port = Integer.parseInt(String.valueOf(secret.getOrDefault("port", 5432)));
        String dbName = (String) secret.getOrDefault("dbname", secret.getOrDefault("database", "postgres"));
        this.dbUser = (String) secret.getOrDefault("username", "postgres");
        this.dbPassword = (String) secret.getOrDefault("password", "");
        this.dbUrl = String.format("jdbc:postgresql://%s:%d/%s", host, port, dbName);

        this.schema = System.getenv().getOrDefault("DB_SCHEMA", "public");
        this.table = System.getenv().getOrDefault("DB_TABLE", "pessoas");
        this.dbEnabled = true;
    }

    // Test/override constructor: if dbUrl is null, disables DB access allowing tests to run without secret.
    public CustomerService(String dbUrl, String dbUser, String dbPassword, String schema, String table) {
        this.dbUrl = dbUrl;
        this.dbUser = dbUser;
        this.dbPassword = dbPassword;
        this.schema = schema != null ? schema : "public";
        this.table = table != null ? table : "pessoas";
        this.dbEnabled = dbUrl != null && !dbUrl.isEmpty();
    }

    /**
     * Find a customer by CPF
     * @param cpf The customer's CPF
     * @return Customer object if found, null otherwise
     */
    public Customer findByCPF(String cpf) {
        if (!dbEnabled) {
            return null; // In test mode, short-circuit
        }
        String cleanCpf = cpf.replaceAll("[^0-9]", "");

        String sql = String.format("SELECT documento, perfil FROM %s.%s WHERE documento = ?", schema, table);

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cleanCpf);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Customer customer = new Customer();
                customer.setCpf(rs.getString("documento"));
                String perfil = rs.getString("perfil");
                // regra de status: por enquanto, considerar 'PADRAO' como ACTIVE
                customer.setStatus("PADRAO".equalsIgnoreCase(perfil) ? "ACTIVE" : "ACTIVE");
                return customer;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error querying PostgreSQL: " + e.getMessage(), e);
        }
    }
}

// Helper JSON utility (minimal) to avoid adding heavy libs beyond Gson already present
class JsonUtils {
    public static Map<String, Object> parseJsonToMap(String json) {
        com.google.gson.Gson gson = new com.google.gson.Gson();
        java.lang.reflect.Type type = new com.google.gson.reflect.TypeToken<Map<String, Object>>() {}.getType();
        return gson.fromJson(json, type);
    }
}
