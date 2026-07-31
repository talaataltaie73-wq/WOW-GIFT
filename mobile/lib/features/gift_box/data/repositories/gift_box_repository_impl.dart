import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/gift_box_entity.dart';
import '../../domain/repositories/gift_box_repository.dart';
import '../data_sources/gift_box_remote_data_source.dart';
import '../models/gift_box_model.dart';

class GiftBoxRepositoryImpl implements GiftBoxRepository {
  final GiftBoxRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  GiftBoxRepositoryImpl(this._remoteDataSource, this._networkInfo);

  static const List<GiftBoxEntity> _mockBoxes = [
    GiftBoxEntity(
      id: '1',
      name: 'صندوق الأناقة',
      description: 'صندوق أنيق بتصميم فاخر مناسب لجميع المناسبات الخاصة',
      price: 25000,
      image: '',
      color: 'ذهبي',
      size: 'وسط',
      maxItems: 5,
    ),
    GiftBoxEntity(
      id: '2',
      name: 'صندوق الرومانسية',
      description: 'صندوق رومانسي باللون الأحمر مثالي لهدايا الحب والذكرى السنوية',
      price: 35000,
      image: '',
      color: 'أحمر',
      size: 'كبير',
      maxItems: 7,
    ),
    GiftBoxEntity(
      id: '3',
      name: 'صندوق الفرح',
      description: 'صندوق وردي مبهج لأعياد الميلاد والتهاني',
      price: 30000,
      image: '',
      color: 'وردي',
      size: 'وسط',
      maxItems: 5,
    ),
    GiftBoxEntity(
      id: '4',
      name: 'صندوق VIP',
      description: 'صندوق فاخر أسود بلمسات ذهبية للهدايا الاستثنائية',
      price: 75000,
      image: '',
      color: 'أسود',
      size: 'كبير',
      maxItems: 10,
    ),
    GiftBoxEntity(
      id: '5',
      name: 'صندوق الطفل',
      description: 'صندوق لطيف بألوان زاهية مخصص لهدايا الأطفال',
      price: 20000,
      image: '',
      color: 'أزرق',
      size: 'صغير',
      maxItems: 4,
    ),
    GiftBoxEntity(
      id: '6',
      name: 'صندوق المحبة',
      description: 'صندوق أخضر أنيق يعبر عن المحبة والتقدير',
      price: 28000,
      image: '',
      color: 'أخضر',
      size: 'صغير',
      maxItems: 4,
    ),
  ];

  @override
  Future<Either<Failure, List<GiftBoxEntity>>> getGiftBoxes() async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockBoxes);
    }
    try {
      final boxes = await _remoteDataSource.getGiftBoxes();
      if (boxes.isEmpty) {
        return Either.right(_mockBoxes);
      }
      return Either.right(boxes);
    } on ServerException {
      return Either.right(_mockBoxes);
    }
  }

  @override
  Future<Either<Failure, GiftBoxEntity>> getGiftBoxDetail(String id) async {
    if (!await _networkInfo.isConnected) {
      final box = _mockBoxes.firstWhere(
        (b) => b.id == id,
        orElse: () => _mockBoxes.first,
      );
      return Either.right(box);
    }
    try {
      final box = await _remoteDataSource.getGiftBoxDetail(id);
      return Either.right(box);
    } on ServerException {
      final box = _mockBoxes.firstWhere(
        (b) => b.id == id,
        orElse: () => _mockBoxes.first,
      );
      return Either.right(box);
    }
  }
}
