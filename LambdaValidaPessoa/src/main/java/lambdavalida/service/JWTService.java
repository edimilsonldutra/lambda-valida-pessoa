package lambdavalida.service;

import lambdavalida.model.Customer;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Service to generate and validate JWT tokens
 */
public class JWTService {

    private final SecretKey secretKey;
    private final long expirationTime;

    public JWTService() {
        // Get secret key from environment variable or use default (NOT RECOMMENDED for production)
        String secret = System.getenv().getOrDefault("JWT_SECRET", "your-256-bit-secret-key-here-please-change-this-in-production-environment");

        // Ensure the key is at least 256 bits (32 bytes) for HS256
        if (secret.length() < 32) {
            secret = String.format("%-32s", secret).replace(' ', '0');
        }

        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));

        // Token expiration time in milliseconds (default: 1 hour)
        String expirationEnv = System.getenv().getOrDefault("JWT_EXPIRATION_MS", "3600000");
        this.expirationTime = Long.parseLong(expirationEnv);
    }

    /**
     * Generate a JWT token for a customer
     * @param customer The customer to generate the token for
     * @return The JWT token
     */
    public String generateToken(Customer customer) {
        Date now = new Date();
        Date expirationDate = new Date(now.getTime() + expirationTime);

        Map<String, Object> claims = new HashMap<>();
        claims.put("cpf", customer.getCpf());
        claims.put("status", customer.getStatus());

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(customer.getCpf())
                .setIssuedAt(now)
                .setExpiration(expirationDate)
                .signWith(secretKey, SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * Validate and parse a JWT token
     * @param token The token to validate
     * @return The claims from the token if valid
     * @throws io.jsonwebtoken.JwtException if the token is invalid
     */
    public Map<String, Object> validateToken(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
