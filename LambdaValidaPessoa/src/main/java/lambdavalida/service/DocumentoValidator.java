package lambdavalida.service;

public class DocumentoValidator {

    public boolean isValid(String documento) {
        if (documento == null || documento.isEmpty()) {
            return false;
        }
        String digits = documento.replaceAll("[^0-9]", "");
        if (digits.length() == 11) {
            return validateCPF(digits);
        } else if (digits.length() == 14) {
            return validateCNPJ(digits);
        }
        return false;
    }

    private boolean validateCPF(String cpf) {
        if (cpf.matches("(\\d)\\1{10}")) {
            return false;
        }
        int sum = 0;
        for (int i = 0; i < 9; i++) {
            sum += Character.getNumericValue(cpf.charAt(i)) * (10 - i);
        }
        int firstCheckDigit = 11 - (sum % 11);
        if (firstCheckDigit >= 10) firstCheckDigit = 0;
        if (Character.getNumericValue(cpf.charAt(9)) != firstCheckDigit) return false;
        sum = 0;
        for (int i = 0; i < 10; i++) {
            sum += Character.getNumericValue(cpf.charAt(i)) * (11 - i);
        }
        int secondCheckDigit = 11 - (sum % 11);
        if (secondCheckDigit >= 10) secondCheckDigit = 0;
        return Character.getNumericValue(cpf.charAt(10)) == secondCheckDigit;
    }

    private boolean validateCNPJ(String cnpj) {
        if (cnpj.matches("(\\d)\\1{13}")) {
            return false;
        }
        int[] weightsFirst = {5,4,3,2,9,8,7,6,5,4,3,2};
        int[] weightsSecond = {6,5,4,3,2,9,8,7,6,5,4,3,2};
        int sum = 0;
        for (int i = 0; i < 12; i++) {
            sum += Character.getNumericValue(cnpj.charAt(i)) * weightsFirst[i];
        }
        int firstCheck = sum % 11;
        firstCheck = (firstCheck < 2) ? 0 : 11 - firstCheck;
        if (Character.getNumericValue(cnpj.charAt(12)) != firstCheck) {
            return false;
        }
        sum = 0;
        for (int i = 0; i < 13; i++) {
            sum += Character.getNumericValue(cnpj.charAt(i)) * weightsSecond[i];
        }
        int secondCheck = sum % 11;
        secondCheck = (secondCheck < 2) ? 0 : 11 - secondCheck;
        return Character.getNumericValue(cnpj.charAt(13)) == secondCheck;
    }

    public String format(String documento) {
        if (documento == null || documento.isEmpty()) return null;
        String digits = documento.replaceAll("[^0-9]", "");
        if (digits.length() == 11) {
            return formatCPF(digits);
        } else if (digits.length() == 14) {
            return formatCNPJ(digits);
        }
        return null;
    }

    public String formatCPF(String cpf) {
        String d = cpf.replaceAll("[^0-9]", "");
        if (d.length() != 11) return null;
        return d.substring(0,3)+"."+d.substring(3,6)+"."+d.substring(6,9)+"-"+d.substring(9);
    }

    public String formatCNPJ(String cnpj) {
        String d = cnpj.replaceAll("[^0-9]", "");
        if (d.length() != 14) return null;
        return d.substring(0,2)+"."+d.substring(2,5)+"."+d.substring(5,8)+"/"+d.substring(8,12)+"-"+d.substring(12);
    }
}
