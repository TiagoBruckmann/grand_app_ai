import 'package:flutter_test/flutter_test.dart';
import 'package:grand_app_ia_challange1/features/echo_text/ui/view_model/echo_text_view_model.dart';

void main() {
  late EchoTextViewModel viewModel;
  late int notifications;

  setUp(() {
    viewModel = EchoTextViewModel();
    notifications = 0;
    viewModel.addListener(() => notifications++);
  });

  tearDown(() => viewModel.dispose());

  test('starts with no echoed text and submit disabled', () {
    expect(viewModel.echoedText, isNull);
    expect(viewModel.canSubmit, isFalse);
  });

  test('cannot submit empty or whitespace-only input', () {
    viewModel.onInputChanged('');
    expect(viewModel.canSubmit, isFalse);

    viewModel.onInputChanged('   ');
    expect(viewModel.canSubmit, isFalse);
  });

  test('can submit when input has text', () {
    viewModel.onInputChanged('Hello');

    expect(viewModel.canSubmit, isTrue);
  });

  test('submit trims the input and resets canSubmit', () {
    viewModel.onInputChanged('  Hello  ');

    viewModel.submit();

    expect(viewModel.echoedText, 'Hello');
    expect(viewModel.canSubmit, isFalse);
  });

  test('submit ignores blank input', () {
    viewModel.onInputChanged('   ');

    viewModel.submit();

    expect(viewModel.echoedText, isNull);
    expect(notifications, 0);
  });

  test('a new submit replaces the previous text', () {
    viewModel
      ..onInputChanged('first')
      ..submit()
      ..onInputChanged('second')
      ..submit();

    expect(viewModel.echoedText, 'second');
  });

  test('notifies only when canSubmit or echoedText changes', () {
    viewModel.onInputChanged('H');
    viewModel.onInputChanged('He');
    viewModel.onInputChanged('Hel');
    expect(notifications, 1);

    viewModel.submit();
    expect(notifications, 2);

    viewModel.onInputChanged('  ');
    expect(notifications, 2);
  });
}
