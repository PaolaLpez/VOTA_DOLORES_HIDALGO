import 'package:flutter_test/flutter_test.dart';
import 'package:vota_dolores_hidalgo/modelos/opcion_votacion.dart';
import 'package:vota_dolores_hidalgo/modelos/votacion.dart';
import 'package:vota_dolores_hidalgo/logica/resultado_voto.dart';
import 'package:vota_dolores_hidalgo/logica/servicio_votacion.dart';

Votacion _crearVotacionDePrueba({DateTime? fechaCierre}) {
  return Votacion(
    pregunta: 'Pregunta de prueba',
    opciones: [
      OpcionVotacion(id: 'op1', texto: 'Opcion 1'),
      OpcionVotacion(id: 'op2', texto: 'Opcion 2'),
    ],
    fechaCierre: fechaCierre ?? DateTime.now().add(const Duration(days: 7)),
  );
}

void main() {
  group('Ronda 1 — Registrar un voto válido', () {
    test('registrar un voto valido incrementa el contador de esa opcion', () {
      final votacion = _crearVotacionDePrueba();
      final servicio = ServicioVotacion(votacion);

      final resultado =
          servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');

      expect(resultado, ResultadoVoto.exitoso);
      expect(votacion.opciones[0].votos, 1);
    });
  });

  group('Ronda 2 — Rechazar votos a opciones que no existen', () {
    test('votar por una opcion que no existe regresa opcionInvalida', () {
      final votacion = _crearVotacionDePrueba();
      final servicio = ServicioVotacion(votacion);

      final resultado =
          servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'no-existe');

      expect(resultado, ResultadoVoto.opcionInvalida);
    });
  });

  group('Ronda 3 — Un usuario no puede votar dos veces', () {
    test('un mismo usuario no puede votar dos veces', () {
      final votacion = _crearVotacionDePrueba();
      final servicio = ServicioVotacion(votacion);

      servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');
      final segundoIntento =
          servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op2');

      expect(segundoIntento, ResultadoVoto.usuarioYaVoto);
      expect(votacion.opciones[1].votos, 0); // op2 no debio incrementarse
    });
  });

  group('Ronda 4 — Calcular resultados con porcentajes', () {
    test('calcula el porcentaje de cada opcion correctamente', () {
      final votacion = _crearVotacionDePrueba();
      final servicio = ServicioVotacion(votacion);

      servicio.registrarVoto(idUsuario: 'u1', idOpcion: 'op1');
      servicio.registrarVoto(idUsuario: 'u2', idOpcion: 'op1');
      servicio.registrarVoto(idUsuario: 'u3', idOpcion: 'op1');
      servicio.registrarVoto(idUsuario: 'u4', idOpcion: 'op2');

      final resultados = servicio.obtenerResultados();
      final op1 = resultados.firstWhere((r) => r.opcion.id == 'op1');
      final op2 = resultados.firstWhere((r) => r.opcion.id == 'op2');

      expect(op1.porcentaje, 75.0);
      expect(op2.porcentaje, 25.0);
    });

    test('si no hay ningun voto, todos los porcentajes son 0', () {
      final votacion = _crearVotacionDePrueba();
      final servicio = ServicioVotacion(votacion);

      final resultados = servicio.obtenerResultados();

      expect(resultados.every((r) => r.porcentaje == 0), true);
    });
  });

  group('Ronda 5 — Determinar el ganador', () {
    test('determinarGanador regresa la opcion con mas votos', () {
      final votacion = _crearVotacionDePrueba();
      final servicio = ServicioVotacion(votacion);

      servicio.registrarVoto(idUsuario: 'u1', idOpcion: 'op1');
      servicio.registrarVoto(idUsuario: 'u2', idOpcion: 'op1');
      servicio.registrarVoto(idUsuario: 'u3', idOpcion: 'op2');

      final ganadores = servicio.determinarGanador();

      expect(ganadores.length, 1);
      expect(ganadores.first.id, 'op1');
    });
  });

  group('Ronda 6 — Reconocer un empate (no elegir al azar)', () {
    test('si hay empate, determinarGanador regresa mas de una opcion', () {
      final votacion = Votacion(
        pregunta: 'Pregunta de prueba',
        opciones: [
          OpcionVotacion(id: 'op1', texto: 'Opcion 1'),
          OpcionVotacion(id: 'op2', texto: 'Opcion 2'),
          OpcionVotacion(id: 'op3', texto: 'Opcion 3'),
        ],
        fechaCierre: DateTime.now().add(const Duration(days: 7)),
      );

      final servicio = ServicioVotacion(votacion);

      servicio.registrarVoto(idUsuario: 'u1', idOpcion: 'op1');
      servicio.registrarVoto(idUsuario: 'u2', idOpcion: 'op2');
      servicio.registrarVoto(idUsuario: 'u3', idOpcion: 'op3');

      final ganadores = servicio.determinarGanador();

      expect(ganadores.length, 3);
    });
  });

  group('Ronda 7 — No se puede votar después del cierre', () {
    test('no se puede votar si la votacion ya cerro', () {
      final votacionCerrada = _crearVotacionDePrueba(
        fechaCierre: DateTime(2000, 1, 1), // una fecha muy en el pasado
      );
      final servicio = ServicioVotacion(votacionCerrada);

      final resultado =
          servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');

      expect(resultado, ResultadoVoto.votacionCerrada);
      expect(votacionCerrada.opciones[0].votos, 0);
    });

    test('si la votacion sigue abierta, el voto se registra normalmente', () {
      final votacionAbierta = _crearVotacionDePrueba(
        fechaCierre: DateTime.now().add(const Duration(days: 1)),
      );
      final servicio = ServicioVotacion(votacionAbierta);

      final resultado =
          servicio.registrarVoto(idUsuario: 'user1', idOpcion: 'op1');

      expect(resultado, ResultadoVoto.exitoso);
    });
  });

  group('Prueba de integración: un plebiscito completo', () {
    test('simulacion completa: varios vecinos votan y se determina un ganador', () {
      final votacion = Votacion(
        pregunta: 'Que obra prioritaria debe realizar el municipio?',
        opciones: [
          OpcionVotacion(id: 'jardin', texto: 'Rehabilitacion del Jardin Principal'),
          OpcionVotacion(id: 'biblioteca', texto: 'Nueva Biblioteca Digital'),
          OpcionVotacion(id: 'alumbrado', texto: 'Alumbrado en el Barrio de Analco'),
        ],
        fechaCierre: DateTime.now().add(const Duration(days: 3)),
      );

      final servicio = ServicioVotacion(votacion);

      servicio.registrarVoto(idUsuario: 'vecino1', idOpcion: 'jardin');
      servicio.registrarVoto(idUsuario: 'vecino2', idOpcion: 'jardin');
      servicio.registrarVoto(idUsuario: 'vecino3', idOpcion: 'biblioteca');
      servicio.registrarVoto(
          idUsuario: 'vecino1', idOpcion: 'alumbrado'); // repetido: no debe contar

      final resultados = servicio.obtenerResultados();
      final totalVotos =
          resultados.fold<double>(0, (s, r) => s + r.opcion.votos);
      final ganadores = servicio.determinarGanador();

      expect(totalVotos, 3); // el intento repetido de vecino1 no debio contar
      expect(ganadores.length, 1);
      expect(ganadores.first.id, 'jardin');
    });
  });
}
