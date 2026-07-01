## Programação de Funcionalidades

A tabela a seguir apresenta as funcionalidades desenvolvidas e os respectivos artefatos de código que as implementam no sistema, divididos entre a interface (Telas), a lógica de negócio (Funcionalidades) e a comunicação com o banco de dados (Domain).

| Funcionalidade | Módulo/Tela | Artefato (Código-Fonte) |
| :--- | :--- | :--- |
| Autenticação de Usuários | Home / Conta | `telas/home_page.dart`, `domain/firebase_auth_repository.dart` |
| Assinatura e Planos | Planos da Empresa | `telas/planos_page.dart`, `funcionalidades/plano.dart` |
| Gestão da Empresa e Estabelecimento | Área da Empresa | `telas/empresa_page.dart`, `funcionalidades/cadastra_empresa.dart`, `domain/firestore_empresa_repository.dart` |
| Mapas e Geolocalização | Seleção de Endereço | `funcionalidades/mapa_selecao.dart`, `funcionalidades/geocoding_service.dart` |
| Geração de QR Code (Empresa) | Criar QR Code | `funcionalidades/gerar_qr_code.dart` |
| Leitura de QR Code (Cliente) | Scanner | `funcionalidades/leitor_qr.dart` |
| Carteira do Cliente | Minhas Carteiras | `telas/cliente_page.dart`, `domain/firestore_cliente_repository.dart` |
| Catálogo e Resgate de Recompensas | Detalhes do Restaurante | `telas/restaurante_detalhe_page.dart`, `funcionalidades/recompensa.dart`, `funcionalidades/pedido.dart` |
| Painel Administrativo (Superusuário)| Admin | `telas/superusuario_painel_page.dart`, `funcionalidades/superusuario.dart` |
