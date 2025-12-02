package lambdavalida;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.google.gson.Gson;
import lambdavalida.model.AuthRequest;
import lambdavalida.model.AuthResponse;
import lambdavalida.model.Customer;
import lambdavalida.service.DocumentoValidator;
import lambdavalida.service.CustomerService;
import lambdavalida.service.JWTService;

import java.util.HashMap;
import java.util.Map;

/**
 * Lambda function handler for customer authentication and validation
 */
public class ValidaPessoaFunction implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

    private final DocumentoValidator cpfValidator;
    private final CustomerService customerService;
    private final JWTService jwtService;
    private final Gson gson;

    public ValidaPessoaFunction() {
        this.cpfValidator = new DocumentoValidator();
        // If running in test (no DB secret), create disabled CustomerService to bypass DB
        String secretArn = System.getenv().getOrDefault("DB_SECRET_ARN", "");
        if (secretArn == null || secretArn.isEmpty()) {
            this.customerService = new CustomerService(null, null, null, null, null);
        } else {
            this.customerService = new CustomerService();
        }
        this.jwtService = new JWTService();
        this.gson = new Gson();
    }

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        Map<String, String> headers = new HashMap<>();
        headers.put("Content-Type", "application/json");
        headers.put("Access-Control-Allow-Origin", "*");
        headers.put("Access-Control-Allow-Methods", "POST, OPTIONS");
        headers.put("Access-Control-Allow-Headers", "Content-Type");

        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent().withHeaders(headers);

        try {
            // Parse request body
            String body = input.getBody();
            if (body == null || body.isEmpty()) {
                return createErrorResponse(response, 400, "Request body is required");
            }

            AuthRequest authRequest = gson.fromJson(body, AuthRequest.class);

            // Validate CPF/CNPJ
            if (!cpfValidator.isValid(authRequest.getCpf())) {
                return createErrorResponse(response, 400, "Documento inválido (CPF/CNPJ)");
            }

            // Check customer in database
            Customer customer = customerService.findByCPF(authRequest.getCpf());

            if (customer == null) {
                return createErrorResponse(response, 404, "Pessoa não encontrada");
            }

            if (!"ACTIVE".equals(customer.getStatus())) {
                return createErrorResponse(response, 403, "Pessoa com status inativo");
            }

            // Generate JWT token
            String token = jwtService.generateToken(customer);

            AuthResponse authResponse = new AuthResponse(token, customer);

            return response
                    .withStatusCode(200)
                    .withBody(gson.toJson(authResponse));

        } catch (Exception e) {
            context.getLogger().log("Error processing request: " + e.getMessage());
            return createErrorResponse(response, 500, "Erro interno ao processar solicitação");
        }
    }

    private APIGatewayProxyResponseEvent createErrorResponse(
            APIGatewayProxyResponseEvent response, int statusCode, String message) {
        Map<String, String> errorBody = new HashMap<>();
        errorBody.put("error", message);
        return response
                .withStatusCode(statusCode)
                .withBody(gson.toJson(errorBody));
    }
}
